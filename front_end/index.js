const examList = new DocumentFragment();
const url = "http://localhost:3000/api/exams";

const exams = document.querySelector(".exams");

fetch(url)
  .then((response) => response.json())
  .then((data) => {
    data.forEach(function (exam) {
      const examBtn = document.createElement("a");
      examBtn.classList.add("exam-link");
      examBtn.setAttribute("type", "button");
      examBtn.setAttribute("href", `http://localhost:3000/exams/${exam['token resultado exame']}`);
      examBtn.textContent = `Token: ${exam["token resultado exame"]} | Paciente: ${exam["nome paciente"]} | Data: ${exam["data exame"]}`;

      examList.appendChild(examBtn);
    });
  })
  .then(() => {
    exams.appendChild(examList);
  })
  .catch(function (error) {
    console.log(error);
  });


const searchForm = document.getElementById('searchform');
const errorMessage = document.querySelector('.search-message');

setTimeout(()=> {
  const examLinks = document.querySelectorAll('.exam-link');
  const examTokens = [];

searchForm.addEventListener('submit', (e)=> {
  e.preventDefault()
  const searchInput = document.querySelector('.search-input');
  const userInput = searchInput.value.toLowerCase();
  const tokenParameter = userInput.trim();

  examLinks.forEach(link => {
    let token = link.href.split('/').pop().toLowerCase();
    examTokens.push(token);
    return [...new Set(examTokens)]
  });

  if (userInput && examTokens.includes(userInput)) {
    window.location.href = `http://localhost:3000/exams/${tokenParameter}`;
    searchInput.value = '';
  } else if (userInput && !examTokens.includes(userInput)) {
    errorMessage.textContent = 'Token inválido'
    setTimeout(()=>{
      errorMessage.textContent = '';
      searchInput.value = '';
      errorMessage.value = 'Busque exame';
      searchInput.focus();
    }, 3000);
  } else {
    errorMessage.textContent = 'Insira um token'
    setTimeout(()=>{
      errorMessage.textContent = '';
      searchInput.value = '';
      errorMessage.value = 'Busque exame';
      searchInput.focus();
    }, 3000)
  }
});

}, 1000)




