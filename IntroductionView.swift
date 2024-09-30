import SwiftUI

struct IntroductionPreview: View {
    let profile: Profile
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ZStack(alignment: .bottomTrailing) {
                    if let image = profile.avatarImage {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 300, alignment: .top)
                            .clipped()
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 300)
                    }
                    
                    VStack(alignment: .trailing) {
                        Text(profile.name)
                            .font(.system(size: 28, weight: .bold))
                        Text(occupationDescription)
                            .font(.system(size: 18, weight: .medium))
                    }
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                    .padding([.bottom, .trailing])
                }
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("關於我")
                        .font(.headline)
                    Text(profile.bio)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("聯繫方式")
                        .font(.headline)
                    
                    LinkRow(title: "電子郵箱", value: profile.email, url: "mailto:\(profile.email)")
                    
                    ForEach(profile.socialLinks) { link in
                        LinkRow(title: link.platform, value: link.username, url: "https://\(link.platform).com/\(link.username)")
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle("個人介紹")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var occupationDescription: String {
        if profile.occupationType == .student {
            return "\(profile.studentDetails.educationLevel.rawValue)\(profile.studentDetails.year)年級"
        } else {
            return profile.jobDetails.position.isEmpty == false ? profile.jobDetails.position : "上班族"
        }
    }
}

struct LinkRow: View {
    let title: String
    let value: String
    let url: String
    @State private var showingAlert = false
    
    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.medium)
            Spacer()
            if let validURL = URL(string: url) {
                Link(value, destination: validURL)
                    .foregroundColor(.blue)
            } else {
                Text(value)
                    .foregroundColor(.blue)
                    .onTapGesture {
                        showingAlert = true
                    }
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("無效的 URL"), message: Text("平台與用戶名不可包含無效的 URL 字符"), dismissButton: .default(Text("確定")))
        }
    }
}
