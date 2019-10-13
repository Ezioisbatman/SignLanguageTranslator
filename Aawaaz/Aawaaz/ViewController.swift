//
//  ViewController.swift
//  Aawaaz
//
//  Created by Shreyash Nigam on 12/10/19.
//  Copyright © 2019 Shreyash Nigam. All rights reserved.
//

import UIKit
import AVKit
import CoreML
import Vision
import AVFoundation

var isTorch = false




enum HandSigns: String {
    
    case A = "A"
    case B = "B"
    case C = "C"
    case D = "D"
    case E = "E"
    case F = "F"
    case G = "G"
    case H = "H"
    case I = "I"
    case J = "J"
    case K = "K"
    case L = "L"
    case M = "M"
    case N = "N"
    case O = "O"
    case P = "P"
    case Q = "Q"
    case R = "R"
    case S = "S"
    case T = "T"
    case U = "U"
    case V = "V"
    case W = "W"
    case X = "X"
    case Y = "Y"
    case Z = "Z"
    case zero = "0"
    case one = "1"
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case bestOfLuck = "Best of luck!"
    case you = "You"
    case iMe = "I/Me"
    case like = "Like"
    case remember = "Remember"
    case love = "Love"
    case fuck = "frick"
    case iLoveYou = "I love you"
    
//    case goru = "goru"
//    case hayir = "hayir"
//    case proje = "proje"
//    case evet = "evet"
//    case nine = "9"
//    case zero = "0"
//    case seven = "7"
//    case luften = "luften"
//    case six = "6"
//    case one = "1"
//    case eight = "8"
//    case a = "a"
//    case Merhaba = "merhaba"
//    case pardon = "pardon"
//    case sess = "sess"
//    case gunya = "gunya"
//    case guzel = "guzel"
//    case nasil = "nasil"
//    case c = "c"
//    case d = "d"
//    case four = "4"
//    case three = "3"
//    case e = "e"
//    case b = "b"
//    case two = "2"
//    case five = "5"
}

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var prediction: UILabel!

    @IBAction func actionTorchClick(_ sender: Any) {
        
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        
        if device.hasTorch {

                isTorch = !isTorch

                do {

                    try device.lockForConfiguration()

                    

                    if isTorch == true {

                        device.torchMode = .on

                    } else {

                        device.torchMode = .off

                    }

                    

                    device.unlockForConfiguration()

                } catch {

                    print("Torch is not working.")

                }

            } else {

                print("Torch not compatible with device.")

            }

        }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureCamera()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func configureCamera() {
        
        // starts the capture session
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        captureSession.startRunning();
        
        // Adding input for capture
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let captureInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(captureInput)
        
        
        // preview layer to see what the camera is seeing
        let layerPrev = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(layerPrev)
        layerPrev.frame = view.frame
        
        
        // Output of capture
        // sample buffer delegate to viewController whose callback is a queue
        // called vidQueue
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "vidQueue"))
        captureSession.addOutput(output);
    }
    
    
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        print("penis 1")
    
        /* Initialise CVPixelBuffer from sample buffer
           CVPixelBuffer is the input type we will feed our coremlmodel .
        */
        
        guard let ogBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { print("conversion failed")
            return }
        let image = CIImage(cvPixelBuffer:ogBuffer)
        let blur = CIFilter(name: "Gauss")
        blur?.setValue(image, forKey: kCIInputImageKey)
        blur?.setValue(11.0, forKey: kCIInputRadiusKey)
        let outputImg = blur?.outputImage
        print("1.5")
        
        let mBlur = CIFilter(name:"median")
        mBlur?.setValue(outputImg, forKey: kCIInputImageKey)
        mBlur?.setValue(15.0, forKey: kCIInputRadiusKey)
        guard let pixelBuffer = mBlur?.outputImage else { print("2354")
            return }
        
        
        print("penis 2")

        /* Initialise Core ML model
           We create a model container to be used with VNCoreMLRequest based on our HandSigns Core ML model.
        */
        guard let handSignsModel = try? VNCoreMLModel(for: new_model().model) else { return }
        
        print("penis 3")

        /* Create a Core ML Vision request
           The completion block will execute when the request finishes execution and fetches a response.
         */
        let request =  VNCoreMLRequest(model: handSignsModel) { (finishedRequest, err) in
            
            print("penis 4")

            /* Dealing with the result of the Core ML Vision request
              The request's result is an array of VNClassificationObservation object which holds
              identifier - The prediction tag we had defined in our Custom Vision model - FiveHand, FistHand, VictoryHand, NoHand
              confidence - The confidence on the prediction made by the model on a scale of 0 to 1
            */
            guard let results = finishedRequest.results as? [VNClassificationObservation]
            else {
                print("data set? more like data shit")
                return
            }

            /* Results array holds predictions iwth decreasing level of confidence.
               Thus we choose the first one with highest confidence. */
            guard let firstResult = results.first else { return }
                                                               
            var predictionString = ""
            print("Big PENISH")
            
            /* Depending on the identifier we set the UILabel text with it's confidence.
               We update UI on the main queue. */
            DispatchQueue.main.async {
                switch firstResult.identifier {
                case HandSigns.A.rawValue:
                    predictionString = "A"
                case HandSigns.B.rawValue:
                    predictionString = "B"
                case HandSigns.C.rawValue:
                    predictionString = "C"
                case HandSigns.D.rawValue:
                    predictionString = "D"
                case HandSigns.E.rawValue:
                    predictionString = "E"
                case HandSigns.F.rawValue:
                    predictionString = "F"
                case HandSigns.G.rawValue:
                    predictionString = "G"
                case HandSigns.H.rawValue:
                    predictionString = "H"
                case HandSigns.I.rawValue:
                    predictionString = "I"
                case HandSigns.J.rawValue:
                    predictionString = "J"
                case HandSigns.K.rawValue:
                    predictionString = "K"
                case HandSigns.L.rawValue:
                    predictionString = "L"
                case HandSigns.M.rawValue:
                    predictionString = "M"
                case HandSigns.N.rawValue:
                    predictionString = "N"
                case HandSigns.O.rawValue:
                    predictionString = "O"
                case HandSigns.P.rawValue:
                    predictionString = "P"
                case HandSigns.Q.rawValue:
                    predictionString = "Q"
                case HandSigns.R.rawValue:
                    predictionString = "R"
                case HandSigns.S.rawValue:
                    predictionString = "S"
                case HandSigns.T.rawValue:
                    predictionString = "T"
                case HandSigns.U.rawValue:
                    predictionString = "U"
                case HandSigns.V.rawValue:
                    predictionString = "V"
                case HandSigns.W.rawValue:
                    predictionString = "W"
                case HandSigns.X.rawValue:
                    predictionString = "X"
                case HandSigns.Y.rawValue:
                    predictionString = "Y"
                case HandSigns.Z.rawValue:
                    predictionString = "Z"
                case HandSigns.zero.rawValue:
                    predictionString = "0"
                case HandSigns.one.rawValue:
                    predictionString = "1"
                case HandSigns.two.rawValue:
                    predictionString = "2"
                case HandSigns.three.rawValue:
                    predictionString = "3"
                case HandSigns.four.rawValue:
                    predictionString = "4"
                case HandSigns.five.rawValue:
                    predictionString = "5"
                case HandSigns.six.rawValue:
                    predictionString = "6"
                case HandSigns.seven.rawValue:
                    predictionString = "7"
                case HandSigns.eight.rawValue:
                    predictionString = "8"
                case HandSigns.nine.rawValue:
                    predictionString = "9"
                case HandSigns.bestOfLuck.rawValue:
                    predictionString = "Best of luck!"
                case HandSigns.you.rawValue:
                    predictionString = "You"
                case HandSigns.iMe.rawValue:
                    predictionString = "I/Me"
                case HandSigns.like.rawValue:
                    predictionString = "Like"
                case HandSigns.remember.rawValue:
                    predictionString = "remember"
                case HandSigns.love.rawValue:
                    predictionString = "Love"
                case HandSigns.fuck.rawValue:
                    predictionString = "frick"
                case HandSigns.iLoveYou.rawValue:
                    predictionString = "I love you"
                    
//                case HandSigns.a.rawValue:
//                    predictionString = "a"
                default:
                    break
                }
                self.prediction.text = predictionString + "(\(firstResult.confidence))"
            }
        }

        /* Perform the above request using Vision Image Request Handler
           We input our CVPixelbuffer to this handler along with the request declared above.
        */
        try? VNImageRequestHandler(ciImage: pixelBuffer, options: [:]).perform([request])
    }

}

