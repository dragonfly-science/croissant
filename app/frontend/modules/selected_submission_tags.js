import $ from 'jquery';
import TaggedSubmissionText from './tagged_submission_text';
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

    function bindSubmissionTagRemoval() {
      $('.js-submission-tag-remove').on('mouseup keydown', function(e) {
        if (e.type === 'mouseup' || e.keyCode === 13) {
          let result = confirm('Are you sure you want to delete this tag?');
          if (result === true) {
            deleteSubmissionTag(this.dataset.stId);
          }
        }
      });
    }

    function deleteSubmissionTag(submissionTagId) {
      $.ajax({
        url: `/submission_tags/${submissionTagId}`,
        dataType: 'json',
        type: 'DELETE'
      })
        .done(response => {
          removeMilestonesAndTagSpan(response.submission_tag.id);
        })
        .fail(response => {
          displayErrors(response.responseJSON.errors);
        });
    }

    function displayErrors(errors) {
      let errorList = $('#tag_removal_error_explanation')
        .clone()
        .removeClass('d-none');
      errors.forEach(error => {
        errorList.append(`<li>${error}</li>`);
      });
      $('.submission__tags-container').prepend(errorList);
    }

    function removeMilestonesAndTagSpan(submissionTagId) {
      let startMilestone = $(
        `hr[data-type='tag-start'][data-id='${submissionTagId}']`
      );
      let endMilestone = $(
        `hr[data-type='tag-end'][data-id='${submissionTagId}']`
      );
      let taggedSubmissionText = new TaggedSubmissionText(
        '.js-tagged-submission'
      );
      let tagsToRerender = taggedSubmissionText.submission
        .find('.js-tag-milestone')
        .toArray();
      taggedSubmissionText.deleteSpansBetweenMilestones(tagsToRerender);

      tagsToRerender = tagsToRerender
        .filter(item => item !== startMilestone[0])
        .filter(item => item !== endMilestone[0]);

      startMilestone.remove();
      endMilestone.remove();
      $(`.js-submission-tag[data-st-id='${submissionTagId}']`).remove();
      taggedSubmissionText.renderMilestones(tagsToRerender);
      // normalize the submission content after removing milestones and
      // rerendering so that sibling text nodes get merged and tagging can
      // operate as normal.
      $('.js-tagged-submission')[0].normalize();
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
          bindSubmissionTagRemoval();
        }
      });
    };
  }
}

export default SelectedSubmissionTags;
