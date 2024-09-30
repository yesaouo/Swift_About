import SwiftUI
import PhotosUI

struct Profile: Identifiable {
    let id = UUID()
    var name: String = ""
    var email: String = ""
    var occupationType: OccupationType = .student
    var studentDetails: StudentDetails = StudentDetails()
    var jobDetails: JobDetails = JobDetails()
    var bio: String = ""
    var socialLinks: [SocialLink] = []
    var avatarImage: Image?
}

enum OccupationType: String, CaseIterable {
    case student = "學生"
    case worker = "上班族"
}

struct StudentDetails {
    var educationLevel: EducationLevel = .undergraduate
    var year: Int = 1
}

enum EducationLevel: String, CaseIterable {
    case undergraduate = "大學"
    case master = "碩士"
    case phd = "博士"
}

struct JobDetails {
    var position: String = ""
}

struct SocialLink: Identifiable {
    let id = UUID()
    var platform: String
    var username: String
}

struct IntroductionForm: View {
    @State private var profile = Profile()
    @State private var showingPreview = false
    @State private var selectedItem: PhotosPickerItem?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本資料")) {
                    TextField("姓名", text: $profile.name)
                    TextField("電子郵箱", text: $profile.email)
                        .keyboardType(.emailAddress)
                    Picker("身份", selection: $profile.occupationType) {
                        ForEach(OccupationType.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                    
                    if profile.occupationType == .student {
                        Picker("教育程度", selection: .init(
                            get: { profile.studentDetails.educationLevel },
                            set: { profile.studentDetails = StudentDetails(educationLevel: $0, year: profile.studentDetails.year) }
                        )) {
                            ForEach(EducationLevel.allCases, id: \.self) {
                                Text($0.rawValue)
                            }
                        }
                        Stepper("年級: \(profile.studentDetails.year)", value: .init(
                            get: { profile.studentDetails.year },
                            set: { profile.studentDetails.year = $0 }
                        ), in: 1...6)
                    } else {
                        TextField("職位", text: .init(
                            get: { profile.jobDetails.position },
                            set: { profile.jobDetails = JobDetails(position: $0) }
                        ))
                    }
                }
                
                Section(header: Text("自我介紹")) {
                    TextEditor(text: $profile.bio)
                        .frame(height: 100)
                }
                
                Section(header: Text("社交媒體")) {
                    ForEach($profile.socialLinks) { $link in
                        HStack {
                            TextField("平台", text: $link.platform)
                            TextField("用戶名", text: $link.username)
                        }
                    }
                    .onDelete(perform: deleteSocialLink)
                    
                    Button(action: addSocialLink) {
                        Label("添加社交媒體", systemImage: "plus")
                    }
                }
                
                Section {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Text("選擇頭像")
                    }
                    .onChange(of: selectedItem, { oldValue, newValue in
                        Task {
                            if let image = try? await newValue?.loadTransferable(type: Image.self) {
                                profile.avatarImage = image
                            }
                        }
                    })
                    if let image = profile.avatarImage {
                        HStack {
                            Spacer()
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                            Spacer()
                        }
                    }
                }
                
                if horizontalSizeClass != .regular {
                    Section {
                        Button(action: {
                            showingPreview = true
                        }) {
                            Text("預覽介紹")
                        }
                    }
                }
            }
            .navigationTitle("個人檔案製作")
            .sheet(isPresented: $showingPreview) {
                IntroductionPreview(profile: profile)
            }
            
            if horizontalSizeClass == .regular {
                IntroductionPreview(profile: profile)
            }
        }
    }
    
    private func addSocialLink() {
        profile.socialLinks.append(SocialLink(platform: "", username: ""))
    }
    
    private func deleteSocialLink(at offsets: IndexSet) {
        profile.socialLinks.remove(atOffsets: offsets)
    }
}

struct ContentView: View {
    var body: some View {
        IntroductionForm()
    }
}
