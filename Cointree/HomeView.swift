import SwiftUI
import Algorithms

struct HomeView: View {
  @EnvironmentObject private var viewModel: CointreeViewModel
  
  
  @State private var showUseCases = true
  @State private var showSolarView = false
  @State private var showSignUp = false
  @State private var showEditWallet = false
  
  @State private var editWalletText: String? = nil
  
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(alignment: .leading, spacing: 10) {
          TipsView(suggestions: [.init(prompt: "Help your local concervancy", image: "forest", url: URL(string: "www.apple.com")!), .init(prompt: "Help your local concervancy", image: "forest", url: URL(string: "www.apple.com")!)])
          Text("Dollars received: $\(viewModel.profile?.dollarsReceived.formatted(.currency(code: "us")) ?? 0.formatted(.currency(code: "us")))")
            .font(.title2)
            .padding([.leading])
          Text("CO2 removed: \(viewModel.profile?.co2Removed.formatted(.number) ?? 0.formatted(.number)) cubic meters")
            .font(.title2)
            .padding([.leading])
        }
        .onAppear {
          if viewModel.profile == nil {
            showSignUp = true
          }
        }
        .sheet(isPresented: $showSignUp) {
          SignUpView()
        }
        .onSubmit(of: .text) {
          guard let editWalletText, !editWalletText.isEmpty else { return }
          viewModel.profile?.walletID = editWalletText
        }
        .sheetWithDetents(isPresented: .constant(!showSolarView && !showEditWallet), detents: [.medium(), .large()], onDismiss: {}) {
          UseCasesView(showSolarView: $showSolarView, showSheet: $showUseCases)
        }
        .navigationTitle("Cointree")
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Menu(content: {
            Group {
              if let walletID = viewModel.profile?.walletID {
                Section {
                  Text("Wallet: \(String(walletID.prefix(6)))...\(String(walletID.suffix(4)))")
                }
                Section {
                  Button(action: { showEditWallet = true }) {
                    Label("Change wallet", systemImage: "pencil.circle")
                  }
                }
              }
            }
          }, label: {
            Image(systemName: "person.circle")
          })
          .foregroundColor(.cointreeGreen)
        }
      }
      .background {
        NavigationLink(isActive: $showSolarView, destination: { InstalledSolar()}, label: {})
      }
      .background {
        NavigationLink(
          isActive: $showEditWallet,
          destination: { ChangeWalletView(onSubmit: { viewModel.profile?.walletID = $0; showEditWallet = false;  }) },
          label: {}
        )
      }
    }
  }
}

struct ChangeWalletView: View {
  let onSubmit: (String) -> Void
  @State private var newWallet = ""
  
  var body: some View {
    Form {
      Section {
        SecureField("New wallet", text: $newWallet, prompt: Text("Add your new wallet here"))
        Button("Submit") { onSubmit(newWallet) }
      }
    }
    .onSubmit(of: .text) {
      onSubmit(newWallet)
    }
    .navigationTitle(Text("Change wallet"))
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
    HomeView()
      .environmentObject(CointreeViewModel())
  }
}

struct UseCasesView: View {
  @Binding var showSolarView: Bool
  @Binding var showSheet: Bool
  @Environment(\.dismiss) private var dismiss
  
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
            Button(action: { showSolarView = true; dismiss() }) {
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
    .onAppear {
      if showSolarView {
        dismiss()
      }
    }
  }
}
