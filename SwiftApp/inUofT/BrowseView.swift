//
//  BrowseView.swift
//  inUofT
//
//  Created by Fata Niazi on 2025-07-31.
//

import SwiftUI

struct BrowseView: View{
    @Binding var showBrowse: Bool
    
    var body: some View {
        NavigationView{
            ScrollView(showsIndicators: false){
                HorizontalGrid()
            }
            .navigationBarTitle(Text("Browse Buildings"), displayMode: .large)
            .navigationBarItems(trailing:
                                    Button(action: {
                self.showBrowse.toggle()
            }) {
                Text("Done").bold()
            })
        }
    }
}

struct HorizontalGrid: View {
    private let gridItemLayout = [GridItem(.fixed(150))]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Category Title")
                .font(.title2).bold()
                .padding(.leading, 22)
                .padding(.top, 10)
        }
        
        ScrollView(.horizontal, showsIndicators: false){
            LazyHGrid(rows: gridItemLayout, spacing: 30){
                ForEach(0..<5) { index  in
                    Color(UIColor.secondarySystemFill)
                        .frame(width: 150, height: 150)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 10)
        }
    }
}
