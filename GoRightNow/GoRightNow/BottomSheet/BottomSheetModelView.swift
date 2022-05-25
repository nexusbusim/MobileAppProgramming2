//
// Created by jeonggyunyun on 2022/05/15.
//

import SwiftUI
import BottomSheetSwiftUI

class BottomSheetModelView: ObservableObject {
    @Published var model: BottomSheetModel = BottomSheetModel()

    var position: BottomSheetPosition {
        get {
            model.bottomSheetPosition
        }

        set {
            model.bottomSheetPosition = newValue
        }
    }

}