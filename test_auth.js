// Test authentication in browser console
// Run this in the browser console on the admin dashboard

console.log('=== Authentication Test ===');
console.log('Token:', localStorage.getItem('adminToken'));
console.log('User:', localStorage.getItem('adminUser'));

// Test API call with token
const token = localStorage.getItem('adminToken');
if (token) {
  fetch('http://localhost:8001/admin/issues', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    },
    body: JSON.stringify({
      name_en: 'Test Issue',
      name_ny: 'Vuto la Test'
    })
  })
  .then(response => response.json())
  .then(data => console.log('API Response:', data))
  .catch(error => console.error('API Error:', error));
} else {
  console.log('No token found - user not logged in');
}