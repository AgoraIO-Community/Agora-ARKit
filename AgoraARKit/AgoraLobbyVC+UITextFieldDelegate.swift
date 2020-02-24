//
//  ViewController+UITextFieldDelegate.swift
//  Agora-ARKit Framework
//
//  Created by Hermes Frangoudis on 1/14/20.
//  Copyright © 2020 Agora.io. All rights reserved.
//

import UIKit

/**
The `AgoraLobbyVC`implements the `UITextFieldDelegate` to handle user input
 - Note: All delegate methods can be extended or overwritten.
*/
extension AgoraLobbyVC: UITextFieldDelegate {
    // MARK: Textfield Delegates
    open func textFieldDidBeginEditing(_ textField: UITextField) {
        lprint("TextField did begin editing method called", .Verbose)
    }

    open func textFieldDidEndEditing(_ textField: UITextField) {
        lprint("TextField did end editing method called", .Verbose)
    }

    open func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        lprint("TextField should begin editing method called", .Verbose)
        return true;
    }

    open func textFieldShouldClear(_ textField: UITextField) -> Bool {
        lprint("TextField should clear method called", .Verbose)
        return true;
    }

    open func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        lprint("TextField should snd editing method called", .Verbose)
        return true;
    }

    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        lprint("While entering the characters this method gets called", .Verbose)
        return true;
    }

    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        lprint("TextField should return method called", .Verbose)
        textField.resignFirstResponder();
        return true;
    }
}
