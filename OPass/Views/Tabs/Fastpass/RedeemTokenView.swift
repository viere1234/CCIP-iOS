//
//  RedeemTokenView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/5.
//  2022 OPass.
//

import SwiftUI
import UIKit
import SlideOverCard
import CodeScanner

struct RedeemTokenView: View {
    
    @State var token: String = ""
    @ObservedObject var eventAPI: EventAPIViewModel
    
    @State var isShowingCameraSOC = false
    @State var isShowingImagePicker = false
    @State var isShowingNoQRCodeAlert = false
    @State var isShowingManuallySOC = false
    @State var isShowingTokenErrorAlert = false
    
    var body: some View {
        VStack {
            Form {
                FastpassLogoView(eventAPI: eventAPI)
                .frame(height: UIScreen.main.bounds.width * 0.4)
                .listRowBackground(Color.white.opacity(0))
                
                Section {
                    Button(action: {
                        isShowingCameraSOC.toggle()
                    }) {
                        HStack {
                            Image(systemName: "camera")
                                .foregroundColor(Color.white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .cornerRadius(9)
                            Text("Scan token with camera").foregroundColor(Color.black)
                            Spacer()
                            Image(systemName: "chevron.right").foregroundColor(.gray)
                        }
                    }
                    .alert("Invaild Token", isPresented: $isShowingTokenErrorAlert) {
                        Button("OK", role: .cancel) {
                            token = ""
                        }
                    }
                    
                    Button(action: {
                        isShowingImagePicker = true
                    }) {
                        HStack {
                            Image(systemName: "photo")
                                .foregroundColor(Color.white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 10)
                                .background(Color.green)
                                .cornerRadius(9)
                            Text("Select a picture to scan token").foregroundColor(Color.black)
                            Spacer()
                            Image(systemName: "chevron.right").foregroundColor(.gray)
                        }
                    }
                    .alert("No QR code found in the picture", isPresented: $isShowingNoQRCodeAlert) {
                        Button("OK", role: .cancel) {
                            isShowingNoQRCodeAlert = false
                        }
                    }
                    
                    Button(action: {
                        isShowingManuallySOC.toggle()
                    }) {
                        HStack {
                            Image(systemName: "keyboard")
                                .foregroundColor(Color.white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 10)
                                .background(Color.purple)
                                .cornerRadius(9)
                            Text("Enter token manually").foregroundColor(Color.black)
                            Spacer()
                            Image(systemName: "chevron.right").foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .slideOverCard(isPresented: $isShowingCameraSOC) {
            VStack {
                Text("Fast Pass").font(Font.largeTitle.weight(.bold))
                Text("Scan token with camera")
                
                //TODO: Handle Camera not permit
                CodeScannerView(codeTypes: [.qr], scanMode: .once, showViewfinder: false, shouldVibrateOnSuccess: true, completion: handleScan)
                    .frame(height: UIScreen.main.bounds.height * 0.25)
                    .cornerRadius(20)
                
                VStack(alignment: .leading) {
                    Text("Scan to get token").bold()
                    Text("Please look for the QRCode provided by the email and place it in the viewfinder")
                        .foregroundColor(Color.gray)
                }
            }
        }
        .slideOverCard(isPresented: $isShowingManuallySOC) {
            VStack {
                Text("Fast Pass").font(Font.largeTitle.weight(.bold))
                Text("Enter token manually")
                
                TextField("Token", text: $token)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.yellow, lineWidth: 2)
                    )
                
                VStack(alignment: .leading) {
                    Text("Please look for the Token provided by the email and enter it in the field above")
                        .foregroundColor(Color.gray)
                        .font(.caption)
                }
                
                Button(action: {
                    UIApplication.shared.endEditing()
                    isShowingManuallySOC.toggle()
                    Task {
                        isShowingTokenErrorAlert = !(await eventAPI.redeemToken(token: token))
                        print(isShowingTokenErrorAlert)
                    }
                }) {
                    HStack {
                        Spacer()
                        Text("Continue")
                            .padding(.vertical, 20)
                            .foregroundColor(Color.white)
                        Spacer()
                    }.background(Color("LogoColor")).cornerRadius(12)
                }
            }
        }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker { selectedImage in
                isShowingImagePicker = false
                if let result = extractFromQRCode(selectedImage) {
                    Task {
                        if !(await eventAPI.redeemToken(token: result)) {
                            DispatchQueue.main.async {
                                isShowingTokenErrorAlert = true
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        isShowingNoQRCodeAlert = true
                    }
                }
            }
        }
    }

    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingCameraSOC = false
        
        switch result {
        case .success(let result):
            Task {
                isShowingTokenErrorAlert = !(await eventAPI.redeemToken(token: result.string))
            }
            print(result.string)
        case .failure(let error):
            isShowingTokenErrorAlert.toggle()
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
    
    func extractFromQRCode(_ image: UIImage) -> String? {
        guard let ciImage = CIImage(image: image),
              let qrCodeDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil) else {
            return nil
        }
        let feature = qrCodeDetector.features(in: ciImage) as! [CIQRCodeFeature]
        return feature.first?.messageString
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#if DEBUG
struct RedeemTokenView_Previews: PreviewProvider {
    static var previews: some View {
        RedeemTokenView(eventAPI: OPassAPIViewModel.mock().eventList[5])
    }
}
#endif
