module TaggingHelpers
  def highlight_selection(range_start, range_end)
    page.execute_script(<<~JS, range_start, range_end)
      (function(rangeStart, rangeEnd) {
        const range = document.createRange();
        const textNodes = getTextNodesIn(submissionText);
        let foundStart = false;
        let charCount = 0, endCharCount;

        range.selectNodeContents(submissionText);

        for (let i = 0, textNode; textNode = textNodes[i]; i++ ) {
          endCharCount = charCount + textNode.length;
          if (!foundStart && rangeStart >= charCount && (rangeStart < endCharCount || (rangeStart == endCharCount && i <= textNodes.length))) {
              range.setStart(textNode, rangeStart - charCount);
              foundStart = true;
          }
          if (foundStart && rangeEnd <= endCharCount) {
              range.setEnd(textNode, rangeEnd - charCount + 1);
              break;
          }
          charCount = endCharCount;
        }

        const sel = window.getSelection();
        sel.removeAllRanges();
        sel.addRange(range);
      })(arguments[0], arguments[1])

      function getTextNodesIn(node) {
        let textNodes = [];
        if (node.nodeType == 3) {
            // node is a text node
            textNodes.push(node);
        } else {
            const children = node.childNodes;
            for (let i = 0, length = children.length; i < length; i++) {
                textNodes.push.apply(textNodes, getTextNodesIn(children[i]));
            }
        }
        return textNodes;
      }
    JS
  end
end
