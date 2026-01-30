export const handleApiError = (error, defaultMessage = 'An error occurred') => {
  console.error('API Error:', error)
  
  if (error.response) {
    const message = error.response.data?.detail || error.response.data?.message || defaultMessage
    return message
  } else if (error.request) {
    // Check if it's a connection refused error
    if (error.code === 'ECONNREFUSED' || error.message?.includes('ECONNREFUSED')) {
      return 'Cannot connect to server. Please make sure the backend API is running on http://localhost:8001'
    }
    return 'Network error - please check your connection and ensure the backend server is running'
  } else {
    return error.message || defaultMessage
  }
}

export const debounce = (func, wait) => {
  let timeout
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout)
      func(...args)
    }
    clearTimeout(timeout)
    timeout = setTimeout(later, wait)
  }
}