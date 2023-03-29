//  SearchBar.swift
import Foundation
import SwiftUI

struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    var onTextDidChange: ((String) -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.delegate = context.coordinator
        
        // Set search bar colors
        searchBar.barTintColor = UIColor(red: 35/255, green: 85/255, blue: 84/255, alpha: 1)
        searchBar.searchTextField.textColor = .white
        searchBar.searchTextField.backgroundColor = UIColor(red: 75/255, green: 125/255, blue: 124/255, alpha: 0.3)
        searchBar.searchTextField.layer.cornerRadius = 8
        searchBar.searchTextField.clipsToBounds = true
        
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
    }

    class Coordinator: NSObject, UISearchBarDelegate {
        let parent: SearchBar

        init(_ searchBar: SearchBar) {
            self.parent = searchBar
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            parent.text = searchText
            parent.onTextDidChange?(searchText)
        }

        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
        }
    }
}
