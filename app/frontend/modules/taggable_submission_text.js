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
        ] = getStartAndEndCharactersForSelection(selection);
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

    function getStartAndEndCharactersForSelection(selection) {
      const selectionAnchorIsTextContainer =
        selection.anchorNode.id === 'js-submissionText';
      let start = 0;
      let end = 0;

      if (selectionAnchorIsTextContainer) {
        // This occurs when trying to add multiple tags sequentially to the same
        // piece of highlighted text. Set the start and end values to mimic the span that is
        // generated after the first successful tag.
        const currentNode =
          selection.anchorNode.childNodes[selection.anchorOffset];
        start = currentNode.dataset.startCharacter;
        end = currentNode.dataset.endCharacter;
      } else {
        let previousSibling = selection.anchorNode.previousElementSibling;

        let siblingOffset = 0;
        if (previousSibling !== null) {
          siblingOffset = parseInt(previousSibling.dataset.endCharacter, 10);
        }
        // anchorOffset is where the user started the selection
        start = selection.anchorOffset + siblingOffset;

        if (previousSibling !== null) {
          start += 1;
        }
        // focusOffset is the character after the selections end
        end = selection.focusOffset + siblingOffset;
        if (previousSibling === null) {
          end -= 1;
        }
      }

      return [start, end];
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
      errors.forEach(error => {
        $('#error_explanation ul').append(
          `<li class="list-group-item list-group-item-danger">${error}</li>`
        );
      });
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
