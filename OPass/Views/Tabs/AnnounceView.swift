//
//  AnnounceView.swift
//  OPass
//
//  Created by secminhr on 2022/3/5.
//  2022 OPass.
//

import SwiftUI

struct AnnounceView: View {
    
    @ObservedObject var eventAPI: EventAPIViewModel
    @State var isError = false
    var announcements: [AnnouncementModel]
    @Environment(\.openURL) var openURL
    
    var body: some View {
        VStack {
            if eventAPI.accessToken != nil {
                if !isError {
                    if !announcements.isEmpty {
                        List(announcements, id: \.datetime) { announcement in
                            Button(action: {
                                if let urlString = announcement.url?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: urlString) {
                                    openURL(url)
                                }
                            }) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(announcement.msg_zh).foregroundColor(.black)
                                        Text(String(format: "%d/%d %d:%02d", announcement.datetime.month, announcement.datetime.day, announcement.datetime.hour, announcement.datetime.minute))
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    if let _ = announcement.url {
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        .refreshable{ try? await eventAPI.loadAnnouncements() }
                        .task{ try? await eventAPI.loadAnnouncements() }
                    } else {
                        VStack {
                            Image(systemName: "tray.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: UIScreen.main.bounds.width * 0.25)
                                .foregroundColor(Color("LogoColor"))
                            Text("Empty Announcement")
                                .font(.title2)
                        }
                        .task{
                            do { try await self.eventAPI.loadAnnouncements() }
                            catch { self.isError = true }
                            //TODO: Need to identify announcement is really empty when catch error
                        }
                    }
                } else {
                    ErrorView {
                        self.isError = false
                        Task {
                            do { try await self.eventAPI.loadAnnouncements() }
                            catch { self.isError = true }
                        }
                    }
                }
            } else {
                RedeemTokenView(eventAPI: eventAPI)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Announcement")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                SFButton(systemName: "arrow.clockwise") {
                    self.isError = false
                    Task {
                        do { try await self.eventAPI.loadAnnouncements() }
                        catch {
                            if self.announcements.isEmpty { self.isError = true }
                            //TODO: Need to identify announcement is really empty when catch error
                        }
                    }
                }
            }
        }
    }
}

struct AnnounceView_Previews: PreviewProvider {
    static var previews: some View {
        AnnounceView(eventAPI: OPassAPIViewModel.mock().currentEventAPI!, announcements: loadJson(filename: "announcementSample.json"))
    }
}
