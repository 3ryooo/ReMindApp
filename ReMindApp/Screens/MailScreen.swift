//
//  MailScreen.swift
//  ReMindApp
//

import SwiftUI
import MessageUI


struct MailScreen: UIViewControllerRepresentable {
    @Binding var isShowing: Bool
    
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        
        // TODO: （待ち）実際のアドレスを入力
        vc.setToRecipients(["a@exaple.com"])
        vc.setSubject("お問い合わせ")
        vc.setMessageBody("", isHTML: false)
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isShowing: $isShowing)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var isShowing: Bool
        
        init(isShowing: Binding<Bool>) {
            _isShowing = isShowing
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            isShowing = false
        }
    }
}
