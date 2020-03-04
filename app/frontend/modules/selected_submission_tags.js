import $ from 'jquery';
import SubmissionTag from './components/submission_tag';

class SelectedSubmissionTags {
  constructor(selector) {
    if ($(selector).length === 0) {
      return;
    }

    function buildSubmissionTag(id) {
      const tagId = $(`hr[data-type='tag-start'][data-id='${id}']`)[0].dataset
        .tagId;
      const tagColour = $(`.submission-tag[data-tag-id='${tagId}']`)[0].dataset
        .tagColour;
      const tagName = $(`.submission-tag[data-tag-id='${tagId}']`)[0].dataset
        .tagName;
      const tagNumber = $(
        `.submission-tag[data-tag-id='${tagId}'] .tag-number`
      )[0].innerText;
      const submissionTag = new SubmissionTag({
        id: id,
        tagColour: tagColour,
        tagName: tagName,
        tagNumber: tagNumber
      });

      $('.js-selected-tags-container').append(submissionTag.build());
    }

    function getSubmissionTagText(submissionTagIds) {
      if (submissionTagIds.length > 1) {
        return $(`.js-tagged[data-st-ids='${submissionTagIds.join()}']`).text();
      }

      const startMilestone = $(
        `hr[data-type='tag-start'][data-id='${submissionTagIds[0]}']`
      );
      const endMilestone = $(
        `hr[data-type='tag-end'][data-id='${submissionTagIds[0]}']`
      );
      const spansAfterMilestone = startMilestone
        .nextAll(`.js-tagged`)
        .toArray();
      const spansBeforeMilestone = endMilestone.prevAll(`.js-tagged`).toArray();
      const submissionTagText = spansAfterMilestone
        .filter(span => spansBeforeMilestone.includes(span))
        .map(span => span.innerText);

      return submissionTagText.join(' ');
    }

    this.displaySubmissionTagDetailsOnClick = function() {
      $('.js-tagged').unbind();
      $('.js-tagged').on('mouseup keydown', function(e) {
        if (e.type === 'mouseup' || e.keyCode === 13) {
          const submissionTagIds = this.dataset.stIds.split(',');
          $('#js-selected-tag-text').text(
            getSubmissionTagText(submissionTagIds)
          );
          $('.js-selected-tags-container').empty();
          $.each(submissionTagIds, (_index, id) => {
            buildSubmissionTag(id);
          });
        }
      });
    };
  }
}

export default SelectedSubmissionTags;
