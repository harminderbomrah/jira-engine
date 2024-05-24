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
  var alertDiv1 = document.getElementById("alert-2");
  alertDiv1.style.display = 'none';
  const alertDiv = document.createElement('div');
  alertDiv.classList.add('alert', 'alert-info', 'alert-dismissible', 'fade', 'show', 'wait-alert');
  alertDiv.setAttribute('role', 'alert');

  alertDiv.innerHTML = `
    Fetching CodeGiant Users, please wait...
  `;
  
  var alertShowDiv = document.getElementById("alert-show");
  alertShowDiv.appendChild(alertDiv);

  document.getElementById('fetch-codegiant-user-button').disabled = true;

  var projectId = document.getElementById('project_id_hidden_field').value;
    
  $.ajax({
    type: 'POST',
    url: `/fetch_codegiant_users`,
    data: { project_id: projectId },
    success: function(response) {
      const successAlertDiv = document.createElement('div');
      successAlertDiv.classList.add('alert', 'alert-info', 'alert-dismissible', 'fade', 'show');
      successAlertDiv.setAttribute('role', 'alert');

      successAlertDiv.textContent = 'CodeGiant users fetched and saved successfully.';

      var alertShowDiv = document.getElementById("alert-show");
      alertShowDiv.appendChild(successAlertDiv);

      setTimeout(function() {
        successAlertDiv.style.display = 'none';
      }, 60000);

      document.getElementById('fetch-codegiant-user-button').disabled = false;

      alertDiv.style.display = 'none';

      document.getElementById('mappingForm').submit();
    },
    error: function(xhr, status, error) {
      const errorAlertDiv = document.createElement('div');
      errorAlertDiv.classList.add('alert', 'alert-info', 'alert-dismissible', 'fade', 'show');
      errorAlertDiv.setAttribute('role', 'alert');
  
      errorAlertDiv.textContent = 'Failed to fetch CodeGiant Users. Please try again later.';
  
      var alertShowDiv = document.getElementById("alert-show");
      alertShowDiv.appendChild(errorAlertDiv);
  
      setTimeout(function() {
        errorAlertDiv.style.display = 'none';
      }, 60000);

      window.location.href = window.location.href;
    },
    complete: function() {
      document.getElementById('fetch-codegiant-user-button').disabled = false;
      
      alertDiv.style.display = 'none';
    }
  });
}
