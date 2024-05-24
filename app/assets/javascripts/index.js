var selectedProjectId = 0;

function select(option) {
  var listItems = document.querySelectorAll('.list-group-item');
  listItems.forEach(function(item) {
    item.classList.remove("selected");
    item.style.backgroundColor = "transparent";
    let txt = item.textContent
    let newtxt = txt.replace("🟢", "").trim();
    item.textContent = newtxt;
  });
  option.classList.add("selected");
  option.innerHTML += "&nbsp;🟢";
  selectedProjectId = option.getAttribute('data-project-id');
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
var alertDiv1 = document.getElementById("alert-2");
alertDiv1.style.display = 'none';
const alertDiv = document.createElement('div');
alertDiv.classList.add('alert', 'alert-info', 'alert-dismissible', 'fade', 'show', 'wait-alert');
alertDiv.setAttribute('role', 'alert');

alertDiv.innerHTML = `
  Fetching Jira Users, please wait...
`;

var alertDiv1 = document.getElementById("alert-show");
alertDiv1.appendChild(alertDiv);

document.getElementById('fetch-issues-button').disabled = true;

var projectId = selectedProjectId;

$.ajax({
  type: 'POST',
  url: `/projects/${projectId}/fetch_assignees`,
  data: { project_id: projectId },
  success: function(response) {
    const successAlertDiv = document.createElement('div');
    successAlertDiv.classList.add('alert', 'alert-info', 'alert-dismissible', 'fade', 'show');
    successAlertDiv.setAttribute('role', 'alert');

    successAlertDiv.textContent = 'Jira Users fetched successfully';

    var alertDiv1 = document.getElementById("alert-show");
    alertDiv1.appendChild(successAlertDiv);

    setTimeout(function() {
      successAlertDiv.style.display = 'none';
    }, 60000);

    document.getElementById('fetch-issues-button').disabled = false;

    alertDiv.style.display = 'none';

    window.location.href = `/edit_importing_project/${projectId}`;
  },
  error: function(xhr, status, error) {
    const errorAlertDiv = document.createElement('div');
    errorAlertDiv.classList.add('alert', 'alert-info', 'alert-dismissible', 'fade', 'show');
    errorAlertDiv.setAttribute('role', 'alert');

    errorAlertDiv.textContent = 'Failed to fetch Jira Users. Please try again later.';

    var alertDiv1 = document.getElementById("alert-show");
    alertDiv1.appendChild(errorAlertDiv);

    setTimeout(function() {
      errorAlertDiv.style.display = 'none';
    }, 60000);
  },
  complete: function() {
    document.getElementById('fetch-issues-button').disabled = false;
    alertDiv.style.display = 'none';
  }
});
}
