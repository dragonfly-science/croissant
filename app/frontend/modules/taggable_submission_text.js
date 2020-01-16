import $ from 'jquery';

class TaggableSubmissionText {
  constructor(selector) {
    if ($(selector).length === 0) {
      return;
    }

    $('.submission-tag').on('click', function() {
      selectHTML(this);
      // add tag pressed text content as data attr to span
      // get start and end character
      // send tag id + start and end character to endpoint for persistance
    });

    function selectHTML(tag) {
      try {
        let text = getSelection().toString();
        let previousSibling = getSelection().anchorNode.previousElementSibling;

        let siblingOffset = 0;
        if (previousSibling !== null) {
          siblingOffset = parseInt(previousSibling.dataset.endCharacter, 10);
        }

        // anchorOffset is where the user started the selection
        let selectionStart = getSelection().anchorOffset + siblingOffset;
        if (previousSibling !== null) {
          selectionStart += 1;
        }
        // focusOffset is the character after the selections end
        let selectionEnd = getSelection().focusOffset + siblingOffset;
        if (previousSibling === null) {
          selectionEnd -= 1;
        }

        let startChar = Math.min(selectionStart, selectionEnd);
        let endChar = Math.max(selectionStart, selectionEnd);

        let tagDataset = $(tag)[0].dataset;

        let submissionId = $('.submission__taggable-text')[0].dataset
          .submissionId;

        let params = {
          submission_tag: {
            submission_id: submissionId,
            tag_id: tagDataset.tagId,
            start_char: startChar,
            end_char: endChar,
            text: text
          }
        };

        persistTag(params);

        let textRange = getSelection().getRangeAt(0);
        let span = document.createElement('span');

        span.setAttribute(
          'class',
          'tagged tagged--colour-' + tagDataset.tagColour
        );
        span.setAttribute('data-tag-name', tagDataset.tagName);
        span.setAttribute('data-start-character', startChar);
        span.setAttribute('data-end-character', endChar);

        textRange.surroundContents(span);

        return span.innerHTML;
      } catch (e) {
        return getSelection();
      }
    }

    function persistTag(params) {
      $.ajax({
        url: '/submission_tags',
        type: 'POST',
        data: params
      })
        .done(data => {
          console.log(data);
        })
        .fail(data => {
          console.log(data);
        });
    }
  }
}

$(document).ready(() => {
  new TaggableSubmissionText('.js-taggable-submission-text');
});
