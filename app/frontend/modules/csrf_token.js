define(['jquery'], $ => {
  let token = $('meta[name="csrf-token"]').attr('content');

  $.ajaxSetup({
    beforeSend: function(xhr) {
      xhr.setRequestHeader('X-CSRF-Token', token);
    }
  });

  return token;
});
