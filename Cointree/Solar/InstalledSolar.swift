import SwiftUI

struct InstalledSolar: View {
  var body: some View {
    ScrollView {
      VStack {
        VStack(alignment: .leading, spacing: 20) {
          Text("So you've installed solar panels...")
            .font(.title2)
            .bold()
            .foregroundColor(.white)
            .padding([.top, .leading])
          Text("Now what?")
            .font(.title2)
            .bold()
            .foregroundColor(.white)
            .padding(.leading)
          TipsView(suggestions: [.init(prompt: "Make sure you received an invoice", image: "solar-install", url: URL(string: "www.apple.com")!)])
            .padding([.bottom])
        }
        .background {
          RoundedRectangle(cornerRadius: 20)
            .foregroundColor(.cointreeGreen)
        }
        .padding(10)
        .padding([.bottom], 40)
        
        Button(action: {}) {
          Text("Scan installation invoice")
            .font(.title3)
            .bold()
            .padding()
            .padding(.horizontal)
            .foregroundColor(.white)
            .background {
              RoundedRectangle(cornerRadius: 10)
            }
        }
      }
      .navigationTitle("Installed solar panels")
      .navigationBarTitleDisplayMode(.inline)
      .padding(.top)
    }
  }
}

struct InstalledSolar_Previews: PreviewProvider {
  static var previews: some View {
    InstalledSolar()
  }
}
