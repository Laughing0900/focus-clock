//
//  FontSelectionView.swift
//  focus-clock
//
//  Created by Laughing Cheng on 30/5/2025.
//

import SwiftUI

struct FontSelectionView: View {
  @ObservedObject var settings: UserSettings

  let fontFamilies = [
    "Academy Engraved LET",
    "Al Nile",
    "American Typewriter",
    "Apple Color Emoji",
    "Apple SD Gothic Neo",
    "Apple Symbols",
    "Arial",
    "Arial Hebrew",
    "Arial Rounded MT Bold",
    "Avenir",
    "Avenir Next",
    "Avenir Next Condensed",
    "Baskerville",
    "Bodoni 72",
    "Bodoni 72 Oldstyle",
    "Bodoni 72 Smallcaps",
    "Bradley Hand",
    "Chalkboard SE",
    "Chalkduster",
    "Cochin",
    "Copperplate",
    "Courier",
    "Courier New",
    "Damascus",
    "Devanagari Sangam MN",
    "Didot",
    "Euphemia UCAS",
    "Farah",
    "Futura",
    "Geeza Pro",
    "Georgia",
    "Gill Sans",
    "Gujarati Sangam MN",
    "Gurmukhi MN",
    "Heiti SC",
    "Heiti TC",
    "Helvetica",
    "Helvetica Neue",
    "Hiragino Mincho ProN",
    "Hiragino Sans",
    "Hoefler Text",
    "Kailasa",
    "Kefa",
    "Khmer Sangam MN",
    "Kohinoor Bangla",
    "Kohinoor Devanagari",
    "Kohinoor Telugu",
    "Lao Sangam MN",
    "Malayalam Sangam MN",
    "Marker Felt",
    "Menlo",
    "Mishafi",
    "Noteworthy",
    "Optima",
    "Oriya Sangam MN",
    "Palatino",
    "Papyrus",
    "Party LET",
    "PingFang HK",
    "PingFang SC",
    "PingFang TC",
    "Plantagenet Cherokee",
    "Savoye LET",
    "Sinhala Sangam MN",
    "Snell Roundhand",
    "Symbol",
    "Tamil Sangam MN",
    "Telugu Sangam MN",
    "Thonburi",
    "Times New Roman",
    "Trebuchet MS",
    "Verdana",
    "Zapf Dingbats",
    "Zapfino",
  ]

  var body: some View {
    List {
      // Preview Section
      Section {
        ZStack {
          RoundedRectangle(cornerRadius: 12)
            .fill(settings.backgroundColor)
            .frame(height: 120)
            .overlay(
              RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )

          VStack(spacing: 8) {
            Text("12:34:56")
              .font(.custom(settings.fontFamily, size: 32 * settings.fontSize))
              .foregroundColor(settings.textColor)

          }
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
        .padding(.horizontal)
        .brightness(settings.brightness - 0.5)
      }

      // Font List Section
      Section("Available Fonts") {
        ForEach(fontFamilies, id: \.self) { fontFamily in
          HStack {
            VStack(alignment: .leading, spacing: 4) {
              Text(fontFamily)
                .font(.custom(fontFamily, size: 16))

              Text(fontFamily)
                .font(.caption2)
                .foregroundColor(.secondary)
            }

            Spacer()

            if settings.fontFamily == fontFamily {
              Image(systemName: "checkmark")
                .foregroundColor(settings.accentColor)
            }
          }
          .contentShape(Rectangle())
          .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
              settings.fontFamily = fontFamily
            }
          }
        }
      }

      // Reset Section
      Section("Reset") {
        Button("Reset to System Default") {
          withAnimation(.easeInOut(duration: 0.2)) {
            settings.fontFamily = "Helvetica Neue"
          }
        }
        .foregroundColor(.red)
      }
    }
    .navigationTitle("Font Family")
    .navigationBarTitleDisplayMode(.inline)
  }
}
