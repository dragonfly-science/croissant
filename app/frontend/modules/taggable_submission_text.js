import $ from 'jquery';

class TaggableSubmissionText {
  constructor(selector) {
    if ($(selector).length === 0) {
      return;
    }

    $('.submission-tag').on('click', function() {
      selectHTML($(this).data('tag-id'));
    });

    function selectHTML(tagId) {
      const selection = getSelection();

      try {
        const [
          selectionStart,
          selectionEnd
        ] = getFirstAndLastCharactersForSelection(selection);
        const text = selection.toString();
        const startChar = Math.min(selectionStart, selectionEnd);
        const endChar = Math.max(selectionStart, selectionEnd);

        const submissionId = $('.submission__taggable-text')[0].dataset
          .submissionId;

        let params = {
          submission_tag: {
            submission_id: submissionId,
            tag_id: tagId,
            start_char: startChar,
            end_char: endChar,
            text: text
          }
        };

        persistSubmissionTag(params);
      } catch (e) {
        return selection;
      }
    }

    function getFirstAndLastCharactersForSelection(selection) {
      const selectionAnchorIsTextContainer =
        selection.anchorNode.id === 'jsSubmissionText';
      let firstTagCharacter = 0;
      let lastTagCharacter = 0;

      if (selectionAnchorIsTextContainer) {
        // This occurs when trying to add multiple tags sequentially to the same
        // piece of highlighted text. Set the start and end values to mimic the span that is
        // generated after the first successful tag.
        const currentNode =
          selection.anchorNode.childNodes[selection.anchorOffset];
        firstTagCharacter = currentNode.dataset.startCharacter;
        lastTagCharacter = currentNode.dataset.endCharacter;

        return [firstTagCharacter, lastTagCharacter];
      }
      // selection.anchorOffset and selection.focusOffset are relative to their parent and sibling nodes.
      // This means that if a new selection is made after or within an existing tag, the offset provided will
      // start at 0 from the end of the sibling or the start of the parent node rather than the beginning of the
      // main text container. Here we need to calculate the actual offset based on the start or end values of those
      // sibling and parent nodes before adding it to the offsets provided to the get actual character values.
      const additionalAnchorOffset = getOffsetForNode(selection.anchorNode);
      const additionalFocusOffset = getOffsetForNode(selection.focusNode);
      const anchorCharacter = selection.anchorOffset + additionalAnchorOffset;
      const focusCharacter = selection.focusOffset + additionalFocusOffset;

      // Anchor is where the selection was started (where the initial click was made) and focus where
      // it was finished (where the mouse was released). Because of this we can't rely on either to consistently be the
      // sequential first or last character so we need to min/max in order to return accurate figures.
      const firstSelectionCharacter = Math.min(anchorCharacter, focusCharacter);

      // The selection offsets used above have some quirks when other html tags are present which mean
      // that characters can be added to the beginning and end of the character count in a few different ways.
      // To resolve that we check the string's index inside the larger body of text starting from
      // the first tag character calculated then use that and the selection's length to figure out the end position.
      const bodyText = $('#jsSubmissionText').text();
      const selectionText = selection.toString();
      firstTagCharacter = bodyText.indexOf(
        selectionText,
        firstSelectionCharacter
      );
      lastTagCharacter = firstTagCharacter + selectionText.length - 1;

      return [firstTagCharacter, lastTagCharacter];
    }

    function getOffsetForNode(node) {
      if (node.previousSibling !== null) {
        // If the node has a previous sibling use its endCharacter as the offset
        return parseInt(node.previousSibling.dataset.endCharacter, 10);
      } else if (node.parentNode.id !== 'jsSubmissionText') {
        // If the nodes parent is another tag
        // (i.e it's nested within or overlapping into another tag)
        // use that parent's startCharacter as the offset.
        return parseInt(node.parentNode.dataset.startCharacter, 10);
      }

      return 0;
    }

    function persistSubmissionTag(params) {
      $.ajax({
        url: '/submission_tags',
        type: 'POST',
        data: params
      })
        .done(response => {
          renderTag(
            response.tag.number,
            response.tag.name,
            response.start_char,
            response.end_char
          );
        })
        .fail(response => {
          displayErrors(response.responseJSON.errors);
        });
    }

    function displayErrors(errors) {
      let errorList = $(`<ul class="pl-5 mb-3 alert alert-danger alert-dismissible" role="alert">
                           <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                             <span aria-hidden="true">&times;</span>
                           </button>
                         </ul>`);

      errors.forEach(error => {
        errorList.append(`<li>${error}</li>`);
      });
      $('#error_explanation').append(errorList);
    }

    function renderTag(tagNumber, tagName, startChar, endChar) {
      let textRange = getSelection().getRangeAt(0);
      let span = document.createElement('span');

      span.setAttribute('class', `tagged tagged--colour-${tagNumber}`);
      span.setAttribute('data-tag-name', tagName);
      span.setAttribute('data-start-character', startChar);
      span.setAttribute('data-end-character', endChar);

      textRange.surroundContents(span);

      return span.innerHTML;
    }
  }
}

$(document).ready(() => {
  new TaggableSubmissionText('.js-taggable-submission-text');
});
