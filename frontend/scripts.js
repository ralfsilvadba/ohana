document.addEventListener('DOMContentLoaded', () => {
  const loginForm = document.getElementById('login-form');
  if (loginForm) {
    loginForm.addEventListener('submit', (e) => {
      e.preventDefault();
      // TODO: implementar chamada de API de login
      window.location.href = 'dashboard.html';
    });
  }

  const createForm = document.getElementById('create-alert-form');
  if (createForm) {
    createForm.addEventListener('submit', (e) => {
      e.preventDefault();
      // TODO: enviar dados de criação via API
      window.location.href = 'dashboard.html';
    });
  }

  const editForm = document.getElementById('edit-alert-form');
  if (editForm) {
    editForm.addEventListener('submit', (e) => {
      e.preventDefault();
      // TODO: enviar atualização via API
      window.location.href = 'dashboard.html';
    });
  }
});
