function openTab(evt, tabName) {
  // Declare all variables
  var i, tabcontent, tablinks;

  // Get all elements with class="tabcontent" and hide them
  tabs = document.getElementsByClassName("sidebar-content");
  for (i = 0; i < tabs.length; i++) {
    tabs[i].style.display = "none";
  }

  // Get all elements with class="tablinks" and remove the class "active"
  tabButtons = document.getElementsByClassName("sidebar-tab-btn");
  for (i = 0; i < tabButtons.length; i++) {
    tabButtons[i].className = tabButtons[i].className.replace(" active", "");
  }

  // Show the current tab, and add an "active" class to the button that opened the tab
  document.getElementById(tabName).style.display = "block";
  evt.currentTarget.className += " active";
} 
