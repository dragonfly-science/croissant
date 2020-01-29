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
        selection.anchorNode.id === 'js-submissionText';
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
      } else {
        let previousSibling = selection.anchorNode.previousElementSibling;

        let siblingOffset = 0;
        if (previousSibling !== null) {
          siblingOffset = parseInt(previousSibling.dataset.endCharacter, 10);
        }
        // anchorOffset is where the user started the selection
        // if the user starts from the end of the tag we want firstTagCharacter to
        // equal the beggining (or smaller) character
        firstTagCharacter =
          Math.min(selection.anchorOffset, selection.focusOffset) +
          siblingOffset;

        if (previousSibling !== null) {
          firstTagCharacter += 1;
        }
        // focusOffset is the character after the selections end
        // if the user starts from the end of the tag we want lastTagCharacter to
        // equal the end (or larger) character
        lastTagCharacter =
          Math.max(selection.anchorOffset, selection.focusOffset) +
          siblingOffset;
        if (previousSibling === null) {
          lastTagCharacter -= 1;
        }
      }

      return [firstTagCharacter, lastTagCharacter];
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
