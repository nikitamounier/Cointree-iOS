import SwiftUI

struct InstalledSolar: View {
  @EnvironmentObject private var viewModel: CointreeViewModel
  
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
        .padding([.bottom], 20)
        
        if let eligibleDollars = viewModel.eligibleAmount {
          
          VStack(alignment: .leading, spacing: 20) {
              Text("Congratulations!")
                .font(.title)
                .bold()
                .foregroundColor(.white)
                .padding([.top, .leading])
            
              Text("You're eligible for $\(eligibleDollars.formatted(.currency(code: "us")))")
                .font(.title2)
                .bold()
                .foregroundColor(.white)
                .padding(.leading)
//            }
            Button(action: {}) {
              Text("Why $\(eligibleDollars.formatted(.currency(code: "us")))?")
                .font(.title3)
                .bold()
                .padding()
                .padding(.horizontal)
                .foregroundColor(.blue)
                .background {
                  RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.white.opacity(0.5))
                }
            }
            .frame(maxWidth: .infinity)
            
            Button(action: { viewModel.}) {
              Text("Receive money")
                .font(.title3)
                .bold()
                .padding()
                .padding(.horizontal)
                .foregroundColor(.white)
                .background {
                  RoundedRectangle(cornerRadius: 10)
                }
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity)
          }
          .background {
            RoundedRectangle(cornerRadius: 20)
              .foregroundColor(.cointreeGreen)
          }
          .padding(10)
          
          
        } else {
          
          Button(action: { viewModel.startDocumentScanner() }) {
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
      }
      .navigationTitle("Installed solar panels")
      .navigationBarTitleDisplayMode(.inline)
      .padding(.top)
    }
  }
}

struct InstalledSolar_Previews: PreviewProvider {
  
  static let viewModel: CointreeViewModel = {
    let vm = CointreeViewModel()
    vm.eligibleAmount = 69
    return vm
  }()
  static var previews: some View {
    InstalledSolar()
      .environmentObject(viewModel)
  }
}
