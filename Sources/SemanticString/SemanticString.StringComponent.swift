extension SemanticString {
    /**
     Part of `SemanticString` that stores text and styles.

     ```
     let boldText = SemanticString("consectetur", styles: [.bold])
     let caption = SemanticString("ipsum dolor sit amet \(boldText) adipisicing", styles: [.callout])
     let result = SemanticString("Lorem \(caption) elit.")
     ```
     `result`'s components:

     ```
     "Lorem "                 styles: []
     "ipsum dolor sit amet "  styles: [callout]
     "consectetur"            styles: [callout, bold]
     " adipisicing"           styles: [callout]
     " elit."                 styles: []
     ```
     */
    public struct StringComponent {
        /**
         sorted styles from outer to inner.
         */
        public let styles: [TextStyle]

        /**
         text part.
         */
        public let content: Content
    }
}
