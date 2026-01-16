// Generate test answer patterns for Core I Beginner assessment
// Correct answers: A,B,D,A,B,C,C,D,C,D,A,D,C,A,B

const correctAnswers = ['A','B','D','A','B','C','C','D','C','D','A','D','C','A','B'];

console.log('=== CORRECT ANSWERS (100% score) ===');
console.log(`['${correctAnswers.join("','")}']`);
console.log(`// ${correctAnswers.length} questions, 100% score`);

console.log('\n=== ALL WRONG ANSWERS (0% score) ===');
const wrongAnswers = correctAnswers.map(correct => {
  // Pick a wrong answer that's not the correct one
  const options = ['A','B','C','D'].filter(opt => opt !== correct);
  return options[0]; // Just pick the first wrong option
});
console.log(`['${wrongAnswers.join("','")}']`);
console.log(`// ${wrongAnswers.length} questions, 0% score`);

console.log('\n=== MIXED ANSWERS (60% score - 9 correct out of 15) ===');
const mixedAnswers = [...correctAnswers];
// Make 6 answers wrong (15 - 9 = 6 wrong)
const wrongIndices = [2, 4, 7, 10, 12, 14]; // Spread out the wrong answers
wrongIndices.forEach(index => {
  const correctAnswer = correctAnswers[index];
  const options = ['A','B','C','D'].filter(opt => opt !== correctAnswer);
  mixedAnswers[index] = options[0];
});
console.log(`['${mixedAnswers.join("','")}']`);
console.log(`// ${mixedAnswers.length} questions, ~60% score (9/15 correct)`);

console.log('\n=== VERIFICATION ===');
let correctCount60 = 0;
for (let i = 0; i < correctAnswers.length; i++) {
  if (correctAnswers[i] === mixedAnswers[i]) correctCount60++;
}
console.log(`60% test: ${correctCount60}/${correctAnswers.length} correct = ${Math.round((correctCount60/correctAnswers.length)*100)}%`);