import $ from 'jquery';

$(document).ready(() => {
  $('.custom-file-input').on('change', e => {
    let fileName = '';
    if (e.target.files.length === 1) {
      fileName = e.target.files[0].name;
    } else {
      fileName = e.target.files.length + ' files selected';
    }
    $(`.custom-file-label[for=${e.currentTarget.id}]`).html(fileName);
  });
});
