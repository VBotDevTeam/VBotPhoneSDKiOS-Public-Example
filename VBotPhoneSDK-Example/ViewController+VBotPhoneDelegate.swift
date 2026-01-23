//
//  ViewController+VBotPhoneDelegate.swift
//  VBotPhoneSDK-Example
//
//  Created by DAT NGUYEN QUOC on 23/1/26.
//

import UIKit
import VBotPhoneSDK
import AVFAudio

// MARK: - VBotPhoneDelegate

extension ViewController: VBotPhoneDelegate {
    
    // MARK: - Call Screen Management
    
    func showCallVC() {
        DispatchQueue.main.async { [weak self] in
            self?.presentCallVCIfNeeded()
        }
    }
    
    func returnToCallVC() {
        DispatchQueue.main.async { [weak self] in
            self?.presentCallVCIfNeeded()
        }
    }
    
    func hideCallVC() {
        DispatchQueue.main.async { [weak self] in
            self?.callViewController?.dismiss(animated: true)
        }
    }
    
    // MARK: - Call Lifecycle
    
    func callStarted() {
        DispatchQueue.main.async { [weak self] in
            self?.presentCallVCIfNeeded()
            self?.callViewController?.didStartOutgoing()
        }
    }
    
    func callAccepted() {
        DispatchQueue.main.async { [weak self] in
            self?.callViewController?.didAccept()
        }
    }
    
    func callStateChanged(state: VBotCallState) {
        DispatchQueue.main.async { [weak self] in
            self?.callViewController?.didUpdateState(state)
        }
    }
    
    func callEnded(reason: VBotEndCallReason) {
        DispatchQueue.main.async { [weak self] in
            self?.callViewController?.didEnd(reason: reason)
            // Delay dismiss để user thấy trạng thái "Kết thúc"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self?.callViewController?.dismiss(animated: true)
                self?.callViewController = nil
            }
        }
    }
    
    // MARK: - Call State Changes
    
    func callMuteStateDidChange(muted: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.callViewController?.syncMuteState(muted)
        }
    }
    
}
