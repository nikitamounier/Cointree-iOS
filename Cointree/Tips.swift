import SwiftUI

struct TipsView: View {
  @Environment(\.openURL) var openURL
  
  let suggestions: [Suggestion]
  var body: some View {
    TabView {
      ForEach(suggestions) { suggestion in
        Image(suggestion.image)
          .resizable()
          .scaledToFill()
          .frame(height: 120)
          .overlay(alignment: .bottom) {
            Button(action: { openURL(suggestion.url) }) {
              HStack {
                Text(suggestion.prompt)
                Spacer()
                Text(Image(systemName: "arrow.forward"))
              }
              .padding()
              .foregroundColor(.white)
            }
          }
      }
    }
    .cornerRadius(30)
    .tabViewStyle(.page(indexDisplayMode: .always))
    .padding(.horizontal, 30)
    .frame(height: 150)
  }
}

struct Suggestion: Identifiable {
  let id = UUID()
  
  let prompt: String
  let image: String
  let url: URL
}

struct TipsView_Previews: PreviewProvider {
  static var previews: some View {
    TipsView(suggestions: [.init(prompt: "Help your local concervancy", image: "forest", url: URL(string: "www.apple.com")!), .init(prompt: "Help your local concervancy", image: "forest", url: URL(string: "www.apple.com")!)])
  }
}
