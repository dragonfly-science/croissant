class SubmissionTag {
  constructor(props) {
    if (props.length === 0) {
      return;
    }

    this.build = function() {
      return `<div class="js-submission-tag selected-tag" data-st-id='${props.id}' data-tag-id='${props.tagId}'>
          <span class="tag-number tag-number--colour-${props.tagColour}">${props.tagNumber}</span>
          ${props.tagName}
          <button class="js-submission-tag-remove selected-tag__delete" data-st-id='${props.id}'>x</button>
        </div>`;
    };
  }
}

export default SubmissionTag;
