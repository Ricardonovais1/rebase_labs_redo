const sendBtn = document.querySelector('.send-btn');
const redirectExams = document.querySelector('.redirect-exams')


function handleUpload() {
  const fileInput = document.getElementById('csvFileInput');
  const file = fileInput.files[0];

  if (!file) {
    alert('Por favor, selecione um arquivo CSV.');
    return;
  }

  if (file.type !== 'text/csv') {
    alert('Por favor, selecione um arquivo CSV válido.');
    return;
  }

  const formData = new FormData();
  formData.append('csvFile', file);

  fetch('/import_csv', {
    method: 'POST',
    body: formData
  }).then(response => {
    if (response.ok) {
      alert('Arquivo CSV enviado com sucesso!');
      redirectExams.classList.remove('hide');
    } else {
      alert('Ocorreu um erro ao enviar o arquivo.');
    }
  }).catch(error => {
    alert('Ocorreu um erro ao enviar o arquivo: ' + error.message);
  });
}

sendBtn.addEventListener('click', handleUpload)

redirectExams.addEventListener('click', () => {
  window.open("http://localhost:3000/exams");
})