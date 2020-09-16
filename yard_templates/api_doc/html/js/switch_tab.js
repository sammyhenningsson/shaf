function openTab(evt, tabName) {
  // Declare all variables
  var i, tabcontent, tablinks;

  tabButtons = document.getElementsByClassName("sidebar-tab-btn");
  for (i = 0; i < tabButtons.length; i++) {
    tabButtons[i].className = tabButtons[i].className.replace(" active", "");
  }

  tabs = document.getElementsByClassName("sidebar-content");
  for (i = 0; i < tabs.length; i++) {
    tabs[i].className = tabs[i].className.replace(" active", "");
  }

  evt.currentTarget.className += " active";
  document.getElementById(tabName).className += " active";
} 
