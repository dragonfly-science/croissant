import $ from 'jquery';

class TaggableSubmissionText {
  constructor(selector) {
    if ($(selector).length === 0) {
      return;
    }

    $('.submission-tag').on('click', function() {
      selectHTML($(this).data("tag-id"));
    });

    function selectHTML(tagId) {
      try {
        const selection = getSelection();
        let selectionStart = 0
        let selectionEnd = 0
        const sameSelection = (selection.anchorNode.id === "js-submissionText")

        if (sameSelection) {
          const currentNode = selection.anchorNode.childNodes[selection.anchorOffset]
          selectionStart = currentNode.dataset.startCharacter
          selectionEnd = currentNode.dataset.endCharacter
        } else {
          let previousSibling = selection.anchorNode.previousElementSibling;

          let siblingOffset = 0;
          if (previousSibling !== null) {
            siblingOffset = parseInt(previousSibling.dataset.endCharacter, 10);
          }
          // anchorOffset is where the user started the selection
          selectionStart = selection.anchorOffset + siblingOffset;

          if (previousSibling !== null) {
            selectionStart += 1;
          }
          // focusOffset is the character after the selections end
          selectionEnd = selection.focusOffset + siblingOffset;
          if (previousSibling === null) {
            selectionEnd -= 1;
          }
        }

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
