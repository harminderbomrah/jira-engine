$(document).ready(function() {
  var csrfToken = $('meta[name="csrf-token"]').attr('content');
  
  $('#cancel-btn').click(function(event) {
    event.preventDefault();
    $.ajax({
      url: '/jira/logout',
      type: 'DELETE',
      headers: {
        'X-CSRF-Token': csrfToken
      },
      success: function(result) {
        const successAlertDiv = document.createElement('div');
        successAlertDiv.classList.add('alert', 'alert-info', 'alert-dismissible', 'fade', 'show');
        successAlertDiv.setAttribute('role', 'alert');
        successAlertDiv.textContent = 'Logout successfully';
        var alertDiv1 = document.getElementById("alert-auth");
        alertDiv1.appendChild(successAlertDiv);
        setTimeout(function() {
          successAlertDiv.style.display = 'none';
        }, 3000);
        window.location.href = '/jira/pages/home';
      },
      error: function(xhr, status, error) {
        const errorAlertDiv = document.createElement('div');
        errorAlertDiv.classList.add('alert', 'alert-info', 'alert-dismissible', 'fade', 'show');
        errorAlertDiv.setAttribute('role', 'alert');
        errorAlertDiv.textContent = 'Logout Failed';
        var alertDiv1 = document.getElementById("alert-auth");
        alertDiv1.appendChild(errorAlertDiv);
        setTimeout(function() {
          errorAlertDiv.style.display = 'none';
        }, 3000);
      }
    });
  });

  $('#next-button').click(function(event) {
    event.preventDefault(); 
    $.ajax({
      url: '/jira/check_authentication',
      method: 'GET',
      headers: {
        'X-CSRF-Token': csrfToken
      },
      success: function(response) {
        if (response.authenticated) {
          var fetchingProjectAlert = $('<div class="alert alert-info" role="alert">Fetching projects, please wait...</div>');
          $('#alert-auth').append(fetchingProjectAlert);
          $.ajax({
            url: '/jira/projects/fetch_latest_projects',
            type: 'POST',
            headers: {
              'X-CSRF-Token': csrfToken
            },
            success: function(response) {
              var alertDiv1 = document.getElementById("alert-auth");
              alertDiv1.innerHTML = '';
              const successProjectAlertDiv = document.createElement('div');
              successProjectAlertDiv.classList.add('alert', 'alert-info', 'alert-dismissible', 'fade', 'show');
              successProjectAlertDiv.setAttribute('role', 'alert');
              successProjectAlertDiv.textContent = 'Latest projects fetched successfully!';
              var alertDiv = document.getElementById("alert-auth");
              alertDiv.appendChild(successProjectAlertDiv);
              setTimeout(function() {
                successProjectAlertDiv.style.display = 'none';
              }, 3000);

              var projectsContainer = $('#projects-container');
              projectsContainer.empty();
              response.projects.forEach(function(project) {
                var projectItem = $('<li class="list-group-item mt-4 list-group-setting"></li>')
                  .text(project.name)
                  .attr('data-project-id', project.id)
                  .on('click', function() {
                    select(this);
                  });
                projectsContainer.append(projectItem);
              });
              debugger;
              $('#authModal').modal('hide');
              $('#projectShowModal').modal('show');
            },
            error: function(xhr, status, error) {
              const errorProjectAlertDiv = document.createElement('div');
              errorProjectAlertDiv.classList.add('alert', 'alert-info', 'alert-dismissible', 'fade', 'show');
              errorProjectAlertDiv.setAttribute('role', 'alert');
              errorProjectAlertDiv.textContent = 'Failed to fetch projects!';
              var alertDiv = document.getElementById("alert-auth");
              alertDiv.appendChild(errorProjectAlertDiv);
              setTimeout(function() {
                errorProjectAlertDiv.style.display = 'none';
              }, 3000);
            }
          });
        }
      },
      error: function() {
        const AuthenticateAlertDiv = document.createElement('div');
        AuthenticateAlertDiv.classList.add('alert', 'alert-info', 'alert-dismissible', 'fade', 'show');
        AuthenticateAlertDiv.setAttribute('role', 'alert');
        AuthenticateAlertDiv.textContent = 'You must be logged in to access this page.';
        var alertDr = document.getElementById("alert-auth");
        alertDr.appendChild(AuthenticateAlertDiv);
        setTimeout(function() {
          AuthenticateAlertDiv.style.display = 'none';
        }, 3000);
      }
    });
  });

  $('.restricted-input').on('input', function() {
    if ($(this).val().length > 3) {
      $(this).val($(this).val().slice(0, 3));
    }
  });

  $('#updateProjectModal form').submit(function(event) {
    event.preventDefault();
    var form = $(this);
    var url = form.attr('action');
    var formData = form.serialize();
    
    $.ajax({
      type: 'PATCH',
      url: url,
      data: formData,
      headers: {
        'X-CSRF-Token': csrfToken
      },
      success: function(response) {
        const successUpdateProjectAlertDiv = document.createElement('div');
        successUpdateProjectAlertDiv.classList.add('alert', 'alert-info', 'alert-dismissible', 'fade', 'show');
        successUpdateProjectAlertDiv.setAttribute('role', 'alert');
        successUpdateProjectAlertDiv.textContent = 'Project Updated Successfully!';
        alertDiv = document.getElementById("alert-update-project");
        alertDiv.appendChild(successUpdateProjectAlertDiv);
        setTimeout(function() {
          successUpdateProjectAlertDiv.style.display = 'none';
        }, 3000);
        $('#updateProjectModal').modal('hide');
        $('#fieldMappingModal').modal('show');
        document.getElementById('project_id_hidden_field').value = selectedProjectId;
      },
      error: function(xhr, status, error) {
        const errorProjectUpdateAlertDiv = document.createElement('div');
        errorProjectUpdateAlertDiv.classList.add('alert', 'alert-info', 'alert-dismissible', 'fade', 'show');
        errorProjectUpdateAlertDiv.setAttribute('role', 'alert');
        errorProjectUpdateAlertDiv.textContent = 'Projects Update Failed!';
        alertDiv = document.getElementById("alert-update-project");
        alertDiv.appendChild(errorProjectUpdateAlertDiv);
        setTimeout(function() {
          errorProjectUpdateAlertDiv.style.display = 'none';
        }, 3000);
      }
    });
  });

  document.getElementById('submitFormButton').addEventListener('click', function() {
    var newInput = document.createElement('input');
    newInput.type = 'hidden';
    newInput.name = 'project_id';
    newInput.value = parseInt(selectedProjectId);
    var tokenInput = document.createElement('input');
    tokenInput.type = 'hidden';
    tokenInput.name = 'authenticity_token';
    tokenInput.value = csrfToken;
    var form = document.getElementById('userMappingForm');
    form.appendChild(newInput);
    form.appendChild(tokenInput);
    form.submit();
  });
});

var selectedProjectId = 0;
var selectedProjectName = '';

function select(option) {
  var listItems = document.querySelectorAll('.list-group-item');
  listItems.forEach(function(item) {
    item.classList.remove("selected");
    item.style.backgroundColor = "transparent";
    let txt = item.textContent;
    let newtxt = txt.replace("🟢", "").trim();
    item.textContent = newtxt;
  });
  option.classList.add("selected");
  option.innerHTML += "&nbsp;🟢";
  selectedProjectId = option.getAttribute('data-project-id');
  selectedProjectName = option.textContent.replace("🟢", "").trim();
  var projectId = option.getAttribute('data-project-id');
  document.getElementById("fetch-issues-button").disabled = false;
}

document.addEventListener("DOMContentLoaded", function() {
  document.getElementById("fetch-issues-button").disabled = true;
  var listItems = document.querySelectorAll('.list-group-item');
  listItems.forEach(function(item) {
    item.addEventListener('click', function() {
      select(this);
    });
  });
});

function showAlertAndDisableButton() {
  var csrfToken = $('meta[name="csrf-token"]').attr('content');
  const jiraAlertDiv = document.createElement('div');
  jiraAlertDiv.classList.add('alert', 'alert-info', 'alert-dismissible', 'fade', 'show', 'wait-alert');
  jiraAlertDiv.setAttribute('role', 'alert');

  jiraAlertDiv.innerHTML = `
    Fetching Jira Users, please wait...
  `;

  var alertDiv = document.getElementById("alert-show");
  alertDiv.appendChild(jiraAlertDiv);

  document.getElementById('fetch-issues-button').disabled = true;

  var projectId = selectedProjectId;

  $.ajax({
    type: 'POST',
    url: `/jira/projects/${projectId}/fetch_assignees`,
    data: { project_id: projectId },
    headers: {
      'X-CSRF-Token': csrfToken
    },
    success: function(response) {
      alertDiv = document.getElementById("alert-show");
      alertDiv.innerHTML = '';
      const successFetchAssigneeAlertDiv = document.createElement('div');
      successFetchAssigneeAlertDiv.classList.add('alert', 'alert-info', 'alert-dismissible', 'fade', 'show');
      successFetchAssigneeAlertDiv.setAttribute('role', 'alert');

      successFetchAssigneeAlertDiv.textContent = 'Jira Users fetched successfully';

      var alertDiv = document.getElementById("alert-show");
      alertDiv.appendChild(successFetchAssigneeAlertDiv);

      setTimeout(function() {
        successFetchAssigneeAlertDiv.style.display = 'none';
      }, 3000);

      document.getElementById('fetch-issues-button').disabled = false;

      $('#projectShowModal').modal('hide');
      $('#updateProjectModal').modal('show');
      document.getElementById('project-id-field').value = selectedProjectId;
      document.getElementById('project-title-field').value = selectedProjectName;
      document.getElementById('modalProjectName').textContent = selectedProjectName;
    },
    error: function(xhr, status, error) {
      const errorFetchAssigneeAlertDiv = document.createElement('div');
      errorFetchAssigneeAlertDiv.classList.add('alert', 'alert-info', 'alert-dismissible', 'fade', 'show');
      errorFetchAssigneeAlertDiv.setAttribute('role', 'alert');

      errorFetchAssigneeAlertDiv.textContent = 'Failed to fetch Jira Users. Please try again later.';

      var alertDiv = document.getElementById("alert-show");
      alertDiv.appendChild(errorFetchAssigneeAlertDiv);

      setTimeout(function() {
        errorFetchAssigneeAlertDiv.style.display = 'none';
      }, 60000);
    },
    complete: function() {
      document.getElementById('fetch-issues-button').disabled = false;
    }
  });
}
function back_to_auth_modal() {
  $('#projectShowModal').modal('hide');
  $('#authModal').modal('show');
}
function back_to_project_show() {
  $('#updateProjectModal').modal('hide');
  $('#projectShowModal').modal('show');
}
function back_to_update_project() {
  $('#fieldMappingModal').modal('hide');
  $('#updateProjectModal').modal('show');
}
function back_to_issue_mapping() {
  $('#userMappingModal').modal('hide');
  $('#fieldMappingModal').modal('show');
}

document.addEventListener('DOMContentLoaded', function() {
  const fieldMappingsModal = document.getElementById('field_mappings_modal');

  function createSelect(name, options) {
    const col = document.createElement('div');
    col.className = 'col';

    const select = document.createElement('select');
    select.className = 'form-control';
    select.name = name;

    Object.entries(options).forEach(([value, text]) => {
      const option = document.createElement('option');
      option.value = value;
      option.textContent = text;
      select.appendChild(option);
    });

    col.appendChild(select);
    return col;
  }

  function addMappingRow(jiraField) {
    const newRow = document.createElement('div');
    newRow.className = 'row field_mapping mb-2';

    const jiraOptions = {
      [jiraField]: jiraField
    };

    newRow.appendChild(createSelect('field_mapping[jira_field][]', jiraOptions));

    const codegiantOptions = {
      '': '',
      'Title': 'Title',
      'Start Date': 'Start Date',
      'Due Date': 'Due Date',
      'Description': 'Description',
      'Story Points': 'Story Points',
      'Estimated Time': 'Estimated Time',
      'Actual Time': 'Actual Time'
    };

    newRow.appendChild(createSelect('field_mapping[codegiant_field][]', codegiantOptions));

    fieldMappingsModal.appendChild(newRow);
  }

  function addMappingRows() {
    const jiraOptions = [
      'summary',
      'description',
      'jira_created_at',
      'due_date',
      'estimated_time',
      'actual_time'
    ];

    jiraOptions.forEach(jiraField => {
      addMappingRow(jiraField);
    });
  }

  addMappingRows();
});

function showAlertAndSubmitForm() {
  showAlert();
}

function showAlert() {
  const alertDiv = document.createElement('div');
  alertDiv.classList.add('alert', 'alert-info', 'alert-dismissible', 'fade', 'show', 'wait-alert');
  alertDiv.setAttribute('role', 'alert');

  alertDiv.innerHTML = `
    Fetching CodeGiant Users, please wait...
  `;

  var alertShowDiv = document.getElementById("alert-field-mapping");
  alertShowDiv.appendChild(alertDiv);

  document.getElementById('fetch-codegiant-user-button').disabled = true;

  var projectId = document.getElementById('project_id_hidden_field').value;
  var csrfToken = $('meta[name="csrf-token"]').attr('content');
    
  $.ajax({
    type: 'POST',
    url: `/jira/fetch_codegiant_users`,
    data: { project_id: projectId },
    headers: {
      'X-CSRF-Token': csrfToken
    },
    success: function(response) {
      const successAlertDiv = document.createElement('div');
      successAlertDiv.classList.add('alert', 'alert-info', 'alert-dismissible', 'fade', 'show');
      successAlertDiv.setAttribute('role', 'alert');

      successAlertDiv.textContent = 'CodeGiant users fetched and saved successfully.';

      var alertShowDiv = document.getElementById("alert-field-mapping");
      alertShowDiv.appendChild(successAlertDiv);

      setTimeout(function() {
        successAlertDiv.style.display = 'none';
      }, 3000);

      document.getElementById('fetch-codegiant-user-button').disabled = false;

      alertDiv.style.display = 'none';

      document.getElementById('mappingForm').submit();
      populateUserMappingForm(response.jira_users, response.code_giant_users);
      $('#fieldMappingModal').modal('hide');
      $('#userMappingModal').modal('show');
    },
    error: function(xhr, status, error) {
      const errorAlertDiv = document.createElement('div');
      errorAlertDiv.classList.add('alert', 'alert-info', 'alert-dismissible', 'fade', 'show');
      errorAlertDiv.setAttribute('role', 'alert');

      errorAlertDiv.textContent = 'Failed to fetch CodeGiant Users. Please try again later.';

      var alertShowDiv = document.getElementById("alert-field-mapping");
      alertShowDiv.appendChild(errorAlertDiv);

      setTimeout(function() {
        errorAlertDiv.style.display = 'none';
      }, 3000);
    },
    complete: function() {
      document.getElementById('fetch-codegiant-user-button').disabled = false;
      alertDiv.style.display = 'none';
    }
  });
}

function populateUserMappingForm(jiraUsers, codeGiantUsers) {
  const userMappingForm = document.getElementById('userMappingForm');
  userMappingForm.innerHTML = '';

  jiraUsers.forEach(user => {
    const row = document.createElement('div');
    row.className = 'row mb-2 mt-4';

    const jiraCol = document.createElement('div');
    jiraCol.className = 'col';
    const jiraSelect = document.createElement('select');
    jiraSelect.name = 'jira_user_ids[]';
    jiraSelect.className = 'form-control';
    const jiraOption = document.createElement('option');
    jiraOption.value = user.id;
    jiraOption.textContent = user.display_name;
    jiraSelect.appendChild(jiraOption);
    jiraCol.appendChild(jiraSelect);

    const codeGiantCol = document.createElement('div');
    codeGiantCol.className = 'col';
    const codeGiantSelect = document.createElement('select');
    codeGiantSelect.name = 'code_giant_user_ids[]';
    codeGiantSelect.className = 'form-control';
    const defaultOption = document.createElement('option');
    defaultOption.value = '';
    defaultOption.textContent = 'Unassigned';
    codeGiantSelect.appendChild(defaultOption);
    codeGiantUsers.forEach(cgUser => {
      const cgOption = document.createElement('option');
      cgOption.value = cgUser.id;
      cgOption.textContent = cgUser.name;
      codeGiantSelect.appendChild(cgOption);
    });
    codeGiantCol.appendChild(codeGiantSelect);

    row.appendChild(jiraCol);
    row.appendChild(codeGiantCol);

    userMappingForm.appendChild(row);
  });
}