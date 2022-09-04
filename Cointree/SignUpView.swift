import SwiftUI

struct SignUpView: View {
  @EnvironmentObject private var viewModel: CointreeViewModel
  @Environment(\.presentationMode) private var presentationMode
  
  @State private var walletID: String = ""
  
  var body: some View {
    VStack {
      Text("Welcome to Cointree")
        .font(.largeTitle)
        .bold()
        .foregroundColor(.white)
        .padding([.horizontal, .bottom])
        .multilineTextAlignment(.center)
      Text("Go green. Get paid")
        .font(.title2)
        .bold()
        .foregroundColor(.white)
        .padding(.horizontal)
        .padding(.bottom, 100)
        .multilineTextAlignment(.center)
      SecureField("Wallet ID", text: $walletID)
        .padding()
        .background {
          RoundedRectangle(cornerRadius: 20)
            .foregroundColor(.white)
            .opacity(0.3)
        }
        .padding(.horizontal)
      Button {
        guard !walletID.isEmpty else { return }
        print("hi")
        viewModel.profile = .init(walletID: walletID, dollarsReceived: 0, co2Removed: 0)
        presentationMode.wrappedValue.dismiss()
        print(viewModel.profile)
      } label: {
        Text("Sign up")
          .font(.title3)
          .bold()
          .padding()
          .padding(.horizontal)
          .foregroundColor(.white)
          .background {
            RoundedRectangle(cornerRadius: 10)
          }
      }
      .padding(.top)
    }
    .frame(maxHeight: .infinity)
    .background(Color.cointreeGreen)
  }
}

struct SignUpView_Previews: PreviewProvider {
  static var previews: some View {
    SignUpView()
      .environmentObject(CointreeViewModel())
  }
}
