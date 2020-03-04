import $ from 'jquery';
import SelectedSubmissionTags from './selected_submission_tags';

class TaggedSubmissionText {
  constructor(selector) {
    if ($(selector).length === 0) {
      return;
    }
    this.submission = $(selector);
    this.selectedSubmissionTags = new SelectedSubmissionTags(
      '.js-selected-tags-container'
    );
  }

  renderAllTags() {
    if (this.submission) {
      let milestones = this.submission.find('.js-tag-milestone');
      this.renderMilestones(milestones);
    }
  }

  rerenderTags($startMilestone, $endMilestone) {
    let allMilestones = this.submission.find('.js-tag-milestone').toArray();
    let startMilestoneIndex = allMilestones.indexOf($startMilestone);
    let endMilestoneIndex = allMilestones.indexOf($endMilestone);
    if (startMilestoneIndex > 0 && endMilestoneIndex > 0) {
      let tagsToRerender = allMilestones.slice(
        startMilestoneIndex,
        endMilestoneIndex + 1
      );
      this.deleteSpansBetweenMilestones(tagsToRerender);
      this.renderMilestones(tagsToRerender);
    } else {
      this.renderAllTags();
    }
  }

  deleteSpansBetweenMilestones(milestones) {
    let spansAndHrs = $(
      '.js-taggable-submission-text hr, .js-taggable-submission-text span'
    ).toArray();
    let first = spansAndHrs.indexOf(milestones[0]);
    let last = spansAndHrs.indexOf(milestones[milestones.length - 1]);
    let firstStartBeforeMilestone = function() {
      let firstStart = first;
      for (let index = first; index > 0; index--) {
        if (spansAndHrs[index].dataset.type === 'tag-start') {
          firstStart = index;
          break;
        }
      }

      return firstStart;
    };
    let firstEndAfterMilestone = function() {
      let firstEnd = last;
      for (let index = last; index < spansAndHrs.length; index++) {
        if (spansAndHrs[index].dataset.type === 'tag-end') {
          firstEnd = index;
          break;
        }
      }

      return firstEnd;
    };

    let elementSubset = spansAndHrs.slice(
      firstStartBeforeMilestone(),
      firstEndAfterMilestone()
    );
    for (let element of elementSubset) {
      if (element.nodeName === 'SPAN') {
        element.replaceWith(element.textContent);
      }
    }
  }

  renderMilestones(milestones) {
    let activeTags = [];
    let activeColours = [];

    for (let milestone of milestones) {
      let type = milestone.dataset.type;
      let tag = milestone.dataset.id;
      let colour = milestone.dataset.colour;
      if (type === 'tag-start') {
        activeTags.push(tag);
        activeColours.push(colour);
      } else if (type === 'tag-end') {
        let index = activeTags.indexOf(tag);
        if (index !== -1) {
          activeTags.splice(index, 1);
        }
        let colourIndex = activeColours.indexOf(colour);
        if (colourIndex !== -1) {
          activeColours.splice(index, 1);
        }
      }
      if (activeTags.length !== 0) {
        let siblingType = milestone.nextSibling.nodeType;
        if (siblingType === Node.TEXT_NODE) {
          $(milestone.nextSibling).wrap(
            this.buildTag(activeColours, activeTags)
          );
        }
      }
    }
    this.selectedSubmissionTags.displaySubmissionTagDetailsOnClick();
  }

  buildTag(activeColours, activeTags) {
    let primaryColourIndex = activeColours.length - 1;
    let primaryColour = activeColours[primaryColourIndex];
    let secondaryColours = activeColours.slice(0, primaryColourIndex);
    let span = document.createElement('span');
    span.classList.add('js-tagged', 'tagged');
    span.classList.add(`tagged--colour-${primaryColour}`);
    span.classList.add(`tagged--count-${activeTags.length}`);
    span.setAttribute('data-st-ids', activeTags);
    span.setAttribute('tabindex', '0');
    span.setAttribute('role', 'button');
    span.setAttribute('aria-pressed', 'false');
    for (let c of secondaryColours) {
      span.classList.add(`tagged--secondary-colour-${c}`);
    }

    return span;
  }
}

export default TaggedSubmissionText;
