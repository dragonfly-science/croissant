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
        let span = document.createElement('span');
        let textRange = getSelection().getRangeAt(0);

        let text = getSelection().toString();

        // anchorOffset is where the user started the selection
        // focusOffset is where the user ended the selection
        let selectionStart = getSelection().anchorOffset;
        let selectionEnd = getSelection().focusOffset;
        let startChar = Math.min([selectionStart, selectionEnd]);
        let endChar = Math.min([selectionStart, selectionEnd]);

        let tagDataset = $(tag)[0].dataset;
        let tagId = tagDataset.tagId;
        let tagName = tagDataset.tagName;
        let tagColour = tagDataset.tagColour;

        let submissionId = $('.submission__taggable-text')[0].dataset
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

        persistTag(params);

        span.setAttribute('class', 'tagged tagged--colour-' + tagColour);
        span.setAttribute('data-tag-name', tagName);
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
