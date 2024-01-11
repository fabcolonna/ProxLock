import SwiftUI

struct PLErrorPanel: View {
    @State var error: String
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
            
            VStack (alignment: .leading) {
                Text("Errore").font(.system(size: 14, weight: .bold))
                
                Text(error)
                    .frame(alignment: .leading)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
            }
            //.frame(width: .infinity)
        }
    }
}
