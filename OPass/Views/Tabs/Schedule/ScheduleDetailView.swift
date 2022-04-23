//
//  ScheduleDetailView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/27.
//  2022 OPass.
//

import SwiftUI
import SwiftDate
import MarkdownUI
import SlideOverCard

struct ScheduleDetailView: View {
    
    @ObservedObject var eventAPI: EventAPIViewModel
    let scheduleDetail: SessionDataModel
    @AppStorage var likedSessions: [String]
    @State var isShowingSpeakerDetail: Bool = false
    @State var showSpeaker: String?
    private var isLiked: Bool {
        likedSessions.contains(scheduleDetail.id)
    }
    
    init(eventAPI: EventAPIViewModel, scheduleDetail: SessionDataModel) {
        _eventAPI = ObservedObject(wrappedValue: eventAPI)
        self.scheduleDetail = scheduleDetail
        _likedSessions = AppStorage(wrappedValue: [], "liked_sessions", store: UserDefaults(suiteName: eventAPI.event_id))
    }
    
    var body: some View {
        List {
            VStack(alignment: .leading, spacing: 0) {
                TagsSection(tagsID: scheduleDetail.tags, tags: eventAPI.eventSchedule?.tags ?? [:])
                    .padding(.vertical, 8)
                
                Text(scheduleDetail.zh.title)
                    .font(.largeTitle.bold())
                    .fixedSize(horizontal: false, vertical: true) //To avoid unexpected line wrapping
                
                FeatureButtons(scheduleDetail: scheduleDetail)
                    .padding(.vertical)
                
                PlaceSection(name: eventAPI.eventSchedule?.rooms[scheduleDetail.room]?.zh.name ?? scheduleDetail.room)
                    .background(Color.white)
                    .cornerRadius(8)
                    .padding(.bottom)
                
                TimeSection(scheduleDetail: scheduleDetail)
                    .background(Color.white)
                    .cornerRadius(8)
            }
            .listRowBackground(Color.transparent)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                
            if scheduleDetail.speakers.count != 0 {
                SpeakersSection(eventAPI: eventAPI, scheduleDetail: scheduleDetail, showSpeaker: $showSpeaker)
            }
            
            if let description = scheduleDetail.zh.description, description != "" {
                DescriptionSection(description: description)
            }
        }
        .listStyle(.insetGrouped)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    SFButton(systemName: "square.and.arrow.up") {
                        
                    }
                    
                    SFButton(systemName: "heart\(isLiked ? ".fill" : "")") {
                        if isLiked {
                            if let index = likedSessions.firstIndex(of: scheduleDetail.id) {
                                likedSessions.remove(at: index)
                            }
                        } else {
                            likedSessions.append(scheduleDetail.id)
                        }
                    }
                }
            }
        }
    }
}

extension String: Identifiable {
    public typealias ID = Int
    public var id: Int {
        return hash
    }
}

fileprivate struct TagsSection: View {
    
    let tagsID: [String]
    let tags: [String : Name_DescriptionPair]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(tagsID, id: \.self) { tagID in
                    Text(tags[tagID]?.zh.name ?? tagID)
                        .font(.caption)
                        .padding(.vertical, 2)
                        .padding(.horizontal, 8)
                        .foregroundColor(Color.black)
                        .background(Color.black.opacity(0.1))
                        .cornerRadius(5)
                }
            }
        }
    }
}

//Feature button size need to be fixed not dynamic 
fileprivate struct FeatureButtons: View {
    
    @Environment(\.openURL) var openURL
    let scheduleDetail: SessionDataModel
    let buttonSize = CGFloat(62)
    let features: [(String, String, String)]
    
    init(scheduleDetail: SessionDataModel) {
        self.scheduleDetail = scheduleDetail
        features = [
            (scheduleDetail.live, "video", "Live"),
            (scheduleDetail.pad, "keyboard", "Co-writing"),
            (scheduleDetail.record, "play", "Record"),
            (scheduleDetail.slide, "paperclip", "Slide"),
            (scheduleDetail.qa, "questionmark", "QA")
        ].filter { (url, _, _) in url != nil } as! [(String, String, String)]
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 12) {
                ForEach(features, id: \.0, content: { (url, systemImageName, text) in
                    VStack {
                        Button(action: {
                            openURL(URL(string: url)!)
                        }) {
                            Image(systemName: systemImageName)
                                .font(.system(size: 23, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(red: 72/255, green: 72/255, blue: 74/255))
                                .frame(width: buttonSize, height: buttonSize)
                                .background(.white)
                                .cornerRadius(10)
                        }
                        Text(text)
                            .font(.caption2)
                            .multilineTextAlignment(.center)
                   }
                })
            }
        }
    }
}

fileprivate struct PlaceSection: View {
    
    let name: String
    
    var body: some View {
        HStack(spacing: 0) {
            Image(systemName: "map").foregroundColor(Color.blue)
                .padding()
            VStack(alignment: .leading) {
                Text("Place").font(.caption)
                    .foregroundColor(.gray)
                Text(name)
            }
            Spacer()
        }
    }
}

fileprivate struct TimeSection: View {
    
    let start: DateInRegion
    let end: DateInRegion
    let durationMinute: Int
    
    init(scheduleDetail: SessionDataModel) {
        self.start = scheduleDetail.start
        self.end = scheduleDetail.end
        self.durationMinute = Int((scheduleDetail.end - scheduleDetail.start) / 60)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Image(systemName: "clock").foregroundColor(Color.red)
                .padding()
            VStack(alignment: .leading) {
                Text(String(format: "%d/%d/%d", start.year, start.month, start.day))
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(String(format: "%d:%02d ~ %d:%02d • %d minutes", start.hour, start.minute, end.hour, end.minute, durationMinute))
            }
            Spacer()
        }
    }
}

fileprivate struct SpeakersSection: View {
    
    @State var forceFullText: Bool = false
    @ObservedObject var eventAPI: EventAPIViewModel
    let scheduleDetail: SessionDataModel
    @Binding var showSpeaker: String?
    
    var body: some View {
        Section("Speakers") {
            ForEach(scheduleDetail.speakers, id: \.self) { speaker in
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .center) {
                        if let avatarURL = eventAPI.eventSchedule?.speakers[speaker]?.avatar {
                            AsyncImage(url: URL(string: avatarURL)) { image in
                                image
                                    .renderingMode(.original)
                                    .resizable().scaledToFit()
                            } placeholder: {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable().scaledToFit()
                                    .foregroundColor(.gray)
                            }
                            .clipShape(Circle())
                            .frame(width: 30, height: 30)
                        }
                        
                        Text(eventAPI.eventSchedule?.speakers[speaker]?.zh.name ?? speaker)
                            .font(.subheadline.bold())
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    if let speakerData = eventAPI.eventSchedule?.speakers[speaker], speakerData.zh.bio != "" {
                        Divider()
                        SpeakerBio(speaker: eventAPI.eventSchedule?.speakers[speaker]?.zh.name ?? speaker, speakerBio: speakerData.zh.bio)
                    }
                }
                .padding(.horizontal, 10)
                .background(Color.white)
                .cornerRadius(8)
                .padding(.bottom, 8)
            }
            .listRowBackground(Color.transparent)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
    }
}

struct SpeakerBio: View {
    let speaker: String
    let speakerBio: String
    @State var isTruncated: Bool = false
    @State var isShowingSpeakerDetail = false
    
    var body: some View {
        VStack(spacing: 0) {
            TruncableMarkdown(text: speakerBio, font: .footnote, lineLimit: 2) {
                isTruncated = $0
            }
            if isTruncated {
                HStack {
                    Spacer()
                    Button("More") {
                        SOCManager.present(isPresented: $isShowingSpeakerDetail, style: .light) {
                            VStack {
                                /*
                                if let avatarURL = eventAPI.eventSchedule?.speakers[speaker]?.avatar {
                                    URLImage(urlString: avatarURL, isRenderOriginal: true, defaultSymbolName: "person.crop.circle.fill")
                                        .clipShape(Circle())
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: UIScreen.main.bounds.width * 0.3, height: UIScreen.main.bounds.width * 0.3)
                                }*/
                                Text(speaker)
                                    .font(.title.bold())
                                
                                if speakerBio != "" {
                                    HStack {
                                        Markdown(speakerBio.tirm())
                                            .markdownStyle(
                                                MarkdownStyle(font: .footnote)
                                            )
                                            .padding()
                                    }
                                    .frame(maxWidth: .infinity)
                                    .background(.white)
                                    .cornerRadius(20)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .font(.footnote)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

fileprivate struct DescriptionSection: View {
    
    let description: String
    
    var body: some View {
        Section("Session Introduction") {
            Markdown(description.tirm())
                .markdownStyle(
                    MarkdownStyle(font: .footnote)
                )
                .padding()
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
}
