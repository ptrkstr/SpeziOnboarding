//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziOnboarding
import SwiftUI

struct OnboardingCustomTestView2: View {
    @EnvironmentObject private var path: OnboardingNavigationPath
    
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Custom Test View 2")
            
            Button {
                path.nextStep()
            } label: {
                Text("Next")
            }
        }
    }
}

#if DEBUG
struct OnboardingCustomTestView2_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingCustomTestView2()
    }
}
#endif