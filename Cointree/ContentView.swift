import SwiftUI
import Algorithms

struct ContentView: View {
  @State private var showUseCases = true
  
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(alignment: .leading, spacing: 10) {
          TipsView(suggestions: [.init(prompt: "Help your local concervancy", image: "forest", url: URL(string: "www.apple.com")!), .init(prompt: "Help your local concervancy", image: "forest", url: URL(string: "www.apple.com")!)])
          Text("Dollars received: $2343.34")
            .font(.title2)
            .padding([.leading])
          Text("CO2 removed: 24398 cubic meters")
            .font(.title2)
            .padding([.leading])
        }
        .sheetWithDetents(isPresented: .constant(true), detents: [.medium(), .large()], onDismiss: nil) {
          UseCasesView()
        }
        .navigationTitle("Cointree")
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {}) {
            Image(systemName: "gearshape.fill")
          }
          .foregroundColor(.cointreeGreen)
        }
      }
    }
  }
}

extension Image {
  init(useCase: UseCase) {
    switch useCase {
    case .solar:
      self.init("solar-panel")
    case .electricVehicle:
      self.init("electricCar")
    case .tree:
      self.init("tree")
    case .publicTransport:
      self.init("bus")
    }
  }
}

extension Text {
  init(useCase: UseCase) {
    switch useCase {
    case .solar:
      self.init("Installed solar panels")
    case .electricVehicle:
      self.init("Bought an electric car")
    case .tree:
      self.init("Planted a tree")
    case .publicTransport:
      self.init("Only used public transport")
    }
  }
}

enum UseCase: Int, CaseIterable, Identifiable {
  case solar = 0
  case electricVehicle
  case tree
  case publicTransport
  
  var id: Int {
    return self.rawValue
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

struct UseCasesView: View {
  var body: some View {
    VStack(alignment: .leading) {
      Text("You have...")
        .font(.title)
        .bold()
        .padding(.top, 40)
        .padding(.leading)
        .foregroundColor(.white)
      ScrollView {
        LazyVGrid(columns: [.init(), .init()], alignment: .center, spacing: 20) {
          ForEach(UseCase.allCases.indexed(), id: \.1.id) { index, useCase in
            Button(action: {}) {
              VStack {
                Image(useCase: useCase)
                  .resizable()
                  .frame(width: 32, height: 32)
                Text(useCase: useCase)
                  .font(.footnote)
                  .bold()
                  .foregroundColor(.white)
              }
              .padding()
              .background {
                RoundedRectangle(cornerRadius: 20)
                  .foregroundColor(.white.opacity(0.1))
                  .frame(width: index.isMultiple(of: 2) ? UIScreen.main.bounds.width / 2 - 20 : UIScreen.main.bounds.width / 2 - 30 , height: 100)
//                  .padding(.trailing, index.isMultiple(of: 2) ? 20 : 0)
                
              }
            }
            .frame(width: index.isMultiple(of: 2) ? UIScreen.main.bounds.width / 2 - 20 : UIScreen.main.bounds.width / 2 - 30, height: 100)
//            .padding(.trailing, index.isMultiple(of: 2) ? 20 : 0)
          }
        }
      }
    }
    .background(Color.cointreeGreen)
  }
}
