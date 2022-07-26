import Flutter
import UIKit
import AWSCognito
import AWSS3

enum ChannelName {
    static let awsS3 = "com.blasanka.s3Flutter/aws_s3"
    static let uploadingSatus = "com.blasanka.s3Flutter/uploading_status"
}

public class SwiftAwsS3Plugin: NSObject, FlutterPlugin {
    private var events: FlutterEventSink?

    var awsAKey : String = ""
    var awsSKey : String = ""

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: ChannelName.awsS3, binaryMessenger: registrar.messenger())
    let eventChannel = FlutterEventChannel(name: ChannelName.uploadingSatus, binaryMessenger: registrar.messenger())
    let instance = SwiftAwsS3Plugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    eventChannel.setStreamHandler(instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch (call.method) {
            case "initAWS":
                    let argsMap = call.arguments as! NSDictionary
                    awsAKey = argsMap["awsAKey"] as! String
                    awsSKey = argsMap["awsSKey"] as! String
                    break;
            case "uploadToS3":
                    self.uploadFile(result: result, args: call.arguments)
                    break;
            case "deleteFromS3":
                    self.delete(result: result, args: call.arguments)
                    break;
            default:
                    result(FlutterMethodNotImplemented)
            }
  }

   private func decideRegion(_ region: String) -> AWSRegionType {
       let reg: String = (region as AnyObject).replacingOccurrences(of: "Regions.", with: "")
       switch reg {
           case "Unknown":
               return AWSRegionType.Unknown
       case "US_EAST_1":
           return AWSRegionType.USEast1
       case "US_EAST_2":
           return AWSRegionType.USEast2
       case "US_WEST_1":
           return AWSRegionType.USWest1
       case "US_WEST_2":
           return AWSRegionType.USWest2
       case "EU_WEST_1":
           return AWSRegionType.EUWest1
       case "EU_WEST_2":
           return AWSRegionType.EUWest2
       case "EU_CENTRAL_1":
           return AWSRegionType.EUCentral1
       case "AP_SOUTHEAST_1":
           return AWSRegionType.APSoutheast1
       case "AP_NORTHEAST_1":
           return AWSRegionType.APNortheast1
       case "AP_NORTHEAST_2":
           return AWSRegionType.APNortheast2
       case "AP_SOUTHEAST_2":
           return AWSRegionType.APSoutheast2
       case "AP_SOUTH_1":
           return AWSRegionType.APSouth1
       case "CN_NORTH_1":
           return AWSRegionType.CNNorth1
       case "CA_CENTRAL_1":
           return AWSRegionType.CACentral1
       case "USGovWest1":
           return AWSRegionType.USGovWest1
       case "CN_NORTHWEST_1":
           return AWSRegionType.CNNorthWest1
       case "EU_WEST_3":
           return AWSRegionType.EUWest3
    //    case "US_GOV_EAST_1":
    //        return AWSRegionType.USGovEast1
    //    case "EU_NORTH_1":
    //        return AWSRegionType.EUNorth1
    //    case "AP_EAST_1":
    //        return AWSRegionType.APEast1
    //    case "ME_SOUTH_1":
    //        return AWSRegionType.MESouth1
       default:
           return AWSRegionType.Unknown
       }
   }
    
    private func uploadFile(result: @escaping FlutterResult, args: Any?) {
        
        let argsMap = args as! NSDictionary
       if let filePath = argsMap["filePath"], let awsFolder = argsMap["awsFolder"],
           let fileNameWithExt = argsMap["fileNameWithExt"], let poolId = argsMap["poolId"],
           let bucketName = argsMap["bucketName"], let region = argsMap["region"] {
            
           let convertedRegion = decideRegion(region as! String)

//           let credentialsProvider = AWSCognitoCredentialsProvider(regionType: convertedRegion, identityPoolId: poolId as! String)
//           let configuration = AWSServiceConfiguration(region: convertedRegion, credentialsProvider: credentialsProvider)

             let credentialsProvider = AWSStaticCredentialsProvider(accessKey: awsAKey, secretKey: awsSKey)
             let configuration = AWSServiceConfiguration(region: AWSRegionType.APSouth1,credentialsProvider: credentialsProvider)

           AWSServiceManager.default().defaultServiceConfiguration = configuration
           let url = NSURL(fileURLWithPath: filePath as! String)
           let fileType: String = (fileNameWithExt as AnyObject).components(separatedBy: ".")[1]
           let uploadRequest = AWSS3TransferManagerUploadRequest()!
           uploadRequest.body = url as URL
        
            let folder = awsFolder as! String
            if (folder != nil && folder != "") {
                uploadRequest.key = folder + "/" + (fileNameWithExt as! String)
            } else {
                uploadRequest.key = (fileNameWithExt as! String)
            }

          uploadRequest.bucket = bucketName as? String
          uploadRequest.contentType = "\(fileType)"
          uploadRequest.acl = .publicReadWrite
          uploadRequest.uploadProgress = { (bytesSent, totalBytesSent,
            totalBytesExpectedToSend) -> Void in
//              DispatchQueue.main.async(execute: {
//               let uploadedPercentage = Float(totalBytesSent) / (Float(bytesSent) + 0.1)
//                   print("byte current \(totalBytesSent) byte total \(bytesSent) percentage \(uploadedPercentage)")
//                    print(Int(uploadedPercentage))
//                    self.events!(Int(uploadedPercentage))
//               })
           }

           let transferManager = AWSS3TransferManager.default()
           transferManager.upload(uploadRequest).continueWith { (task) -> AnyObject? in
               if let error = task.error as NSError? {
                   if error.domain == AWSS3TransferManagerErrorDomain as String {
                       if let errorCode = AWSS3TransferManagerErrorType(rawValue: error.code) {
                           switch (errorCode) {
                           case .cancelled, .paused:
                                   print("upload failed .cancelled, .paused:")
                                   result(nil)
                                   break;
                           default:
                                   print("upload() failed: defaultd [\(error)]")
                                   result(nil)
                                   break;
                           }
                       } else {
                           print("upload() failed: [\(error)]")
                           result(nil)
                       }
                   } else {
                       //upload failed
                       print("upload() failed: domain [\(error)]")
                       result(FlutterError(code: "UNAVAILABLE", message: "Battery info unavailable", details: nil))
                   }
               }

               if task.result != nil {
                   print("✅ Upload successed (\(fileNameWithExt))")
                   result(fileNameWithExt)
               }
               return nil
           }
       } else {
           print("Did not provided required args")
           result(nil)
       }
    }


    private func delete(result: @escaping FlutterResult, args: Any?) {
            let argsMap = args as! NSDictionary
            if  let filePath = argsMap["filePath"], let subRegion = argsMap["subRegion"],
                let poolID = argsMap["poolID"],
                let bucketName = argsMap["bucketName"], let region = argsMap["region"]{

                let parsedRegion = "\(region)".aws_regionTypeValue
                let parsedSubRegion = subRegion as! String != "" ? "\(subRegion)".aws_regionTypeValue : parsedRegion

//                 let credentialsProvider = AWSCognitoCredentialsProvider(regionType: parsedRegion(), identityPoolId: poolID as! String)
//                 let configuration = AWSServiceConfiguration(region: parsedSubRegion(), credentialsProvider: credentialsProvider)

                let credentialsProvider = AWSStaticCredentialsProvider(accessKey: awsAKey, secretKey: awsSKey)
                let configuration = AWSServiceConfiguration(region: AWSRegionType.APSouth1,credentialsProvider: credentialsProvider)

                AWSServiceManager.default().defaultServiceConfiguration = configuration

                AWSS3.register(with: configuration!, forKey: "defaultKey")
                let s3 = AWSS3.s3(forKey: "defaultKey")
                let deleteObjectRequest = AWSS3DeleteObjectRequest()
                deleteObjectRequest?.bucket = (bucketName as! String)
                deleteObjectRequest?.key = (filePath as! String)
                s3.deleteObject(deleteObjectRequest!).continueWith { (task:AWSTask) -> AnyObject? in
                     if let error = task.error as NSError?{
                        print("Native: Failed: \(error)")
                        result(false)
                        return nil
                    }

                   if task.result != nil {
                        result(true)
                    }
                    return nil
                }

            }else {
                print("Native: One or more arguments is missing while calling func()")
                result(nil)
            }
        }
}


extension SwiftAwsS3Plugin : FlutterStreamHandler {
    
    public func onListen(withArguments arguments: Any?,
                         eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.events = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.events = nil
        return nil
    }
}
