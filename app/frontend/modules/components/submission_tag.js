class SubmissionTag {
  constructor(props) {
    if (props.length === 0) {
      return;
    }

    this.build = function() {
      return `<div class="js-submission-tag selected-tag" data-st-id='${props.id}' data-tag-id='${props.tagId}'>
          <span class="tag-number tag-number--colour-${props.tagColour}">${props.tagNumber}</span>
          ${props.tagName}
          <a class="js-submission-tag-remove selected-tag__delete" data-confirm="Are you sure you want to delete this tag?" rel="nofollow" data-method="delete" href="/submission_tags/${props.id}">x</a>
        </div>`;
    };
  }
}

export default SubmissionTag;
