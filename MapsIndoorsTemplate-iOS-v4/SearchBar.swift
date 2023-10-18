import SwiftUI

struct SearchBar: UIViewRepresentable {
    @Binding var text: String

    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text)
    }

    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        
        // Set the background to be transparent
        searchBar.barTintColor = UIColor.clear
        searchBar.backgroundColor = UIColor.clear
        searchBar.isTranslucent = true
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        searchBar.searchBarStyle = .minimal
        
        // Customize the appearance of the text field inside the search bar
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = UIColor.white
            textField.layer.cornerRadius = 10.0
            textField.clipsToBounds = true
            textField.textColor = UIColor.black
            textField.font = UIFont.systemFont(ofSize: 16)
            
            // Set a placeholder text
            textField.attributedPlaceholder = NSAttributedString(string: "Search for buildings or locations...",
                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
            
            // Change the color of the search icon
            let searchIcon = textField.leftView as? UIImageView
            searchIcon?.image = searchIcon?.image?.withRenderingMode(.alwaysTemplate)
            searchIcon?.tintColor = UIColor.black
            
            // Make the text field's edges rounded
            textField.layer.cornerRadius = 15.0
            textField.clipsToBounds = true
        }
        
        // Set the keyboard appearance
        searchBar.keyboardAppearance = .light
        
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
}
