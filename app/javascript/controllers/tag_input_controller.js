import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "list"]

  connect() {
    this.selectedTags = new Set()
    this.newTags = new Set()
    this.debounceTimer = null
    this.updateHiddenFields()
  }

  inputChanged() {
    const query = this.inputTarget.value.trim()
    
    // Clear existing timer
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer)
    }

    // Debounce the search to avoid too many requests
    this.debounceTimer = setTimeout(() => {
      if (query.length > 0) {
        this.searchTags(query)
      } else {
        this.clearSuggestions()
      }
    }, 300)
  }

  async searchTags(query) {
    try {
      const response = await fetch(`/tags?q=${encodeURIComponent(query)}`, {
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest'
        }
      })
      
      if (response.ok) {
        const tags = await response.json()
        this.displaySuggestions(tags, query)
      }
    } catch (error) {
      console.error('Error fetching tags:', error)
    }
  }

  displaySuggestions(tags, query) {
    this.listTarget.innerHTML = ''
    
    // Show existing tags that match
    const existingTags = tags.filter(tag => 
      tag.name.toLowerCase().includes(query.toLowerCase()) && 
      !this.selectedTags.has(tag.id.toString())
    )

    existingTags.forEach(tag => {
      const tagElement = this.createTagSuggestion(tag.name, 'existing', tag.id)
      this.listTarget.appendChild(tagElement)
    })

    // Show option to create new tag if query doesn't exactly match any existing tag
    const exactMatch = tags.some(tag => tag.name.toLowerCase() === query.toLowerCase())
    if (!exactMatch && query.length > 0) {
      const newTagElement = this.createTagSuggestion(`Create "${query}"`, 'new', query)
      this.listTarget.appendChild(newTagElement)
    }

    // Process comma-separated input
    if (query.includes(',')) {
      this.processCommaSeparatedInput(query)
    }
  }

  createTagSuggestion(text, type, value) {
    const div = document.createElement('div')
    div.className = 'p-2 hover:bg-purple-100 cursor-pointer border-b border-purple-200 last:border-b-0'
    div.textContent = text
    div.dataset.type = type
    div.dataset.value = value
    
    div.addEventListener('click', (e) => {
      e.preventDefault()
      this.selectTag(type, value, text)
    })
    
    return div
  }

  processCommaSeparatedInput(input) {
    const tags = input.split(',').map(tag => tag.trim()).filter(tag => tag.length > 0)
    const lastTag = tags[tags.length - 1]
    
    // Add all complete tags (except the last one which might still be being typed)
    for (let i = 0; i < tags.length - 1; i++) {
      const tagName = tags[i]
      if (tagName) {
        this.newTags.add(tagName)
      }
    }
    
    // Update input to show only the last tag being typed
    this.inputTarget.value = lastTag || ''
    this.updateHiddenFields()
    this.displaySelectedTags()
  }

  selectTag(type, value, displayText) {
    if (type === 'existing') {
      this.selectedTags.add(value.toString())
    } else if (type === 'new') {
      this.newTags.add(value)
    }
    
    this.inputTarget.value = ''
    this.clearSuggestions()
    this.updateHiddenFields()
    this.displaySelectedTags()
  }

  displaySelectedTags() {
    // Create a container for selected tags if it doesn't exist
    let selectedContainer = this.element.querySelector('.selected-tags')
    if (!selectedContainer) {
      selectedContainer = document.createElement('div')
      selectedContainer.className = 'selected-tags mt-2 flex flex-wrap gap-2'
      this.inputTarget.parentNode.insertBefore(selectedContainer, this.listTarget)
    }

    selectedContainer.innerHTML = ''

    // Display existing selected tags
    this.selectedTags.forEach(tagId => {
      const tagElement = this.createSelectedTag(`Tag ${tagId}`, 'existing', tagId)
      selectedContainer.appendChild(tagElement)
    })

    // Display new tags
    this.newTags.forEach(tagName => {
      const tagElement = this.createSelectedTag(tagName, 'new', tagName)
      selectedContainer.appendChild(tagElement)
    })
  }

  createSelectedTag(text, type, value) {
    const span = document.createElement('span')
    span.className = 'inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-purple-100 text-purple-800'
    
    const textSpan = document.createElement('span')
    textSpan.textContent = text
    span.appendChild(textSpan)
    
    const removeBtn = document.createElement('button')
    removeBtn.type = 'button'
    removeBtn.className = 'ml-2 text-purple-600 hover:text-purple-800'
    removeBtn.innerHTML = '×'
    removeBtn.addEventListener('click', (e) => {
      e.preventDefault()
      this.removeTag(type, value)
    })
    
    span.appendChild(removeBtn)
    return span
  }

  removeTag(type, value) {
    if (type === 'existing') {
      this.selectedTags.delete(value.toString())
    } else if (type === 'new') {
      this.newTags.delete(value)
    }
    
    this.updateHiddenFields()
    this.displaySelectedTags()
  }

  updateHiddenFields() {
    // Update existing tag IDs
    const tagIdsField = document.getElementById('journal_entry_tag_ids')
    if (tagIdsField) {
      // Remove existing hidden inputs
      const existingInputs = document.querySelectorAll('input[name="journal_entry[tag_ids][]"]')
      existingInputs.forEach(input => input.remove())
      
      // Add new hidden inputs for each selected tag
      this.selectedTags.forEach(tagId => {
        const hiddenInput = document.createElement('input')
        hiddenInput.type = 'hidden'
        hiddenInput.name = 'journal_entry[tag_ids][]'
        hiddenInput.value = tagId
        tagIdsField.parentNode.appendChild(hiddenInput)
      })
    }

    // Update new tags
    const newTagsField = document.getElementById('journal_entry_new_tags')
    if (newTagsField) {
      // Remove existing hidden inputs
      const existingInputs = document.querySelectorAll('input[name="journal_entry[new_tags][]"]')
      existingInputs.forEach(input => input.remove())
      
      // Add new hidden inputs for each new tag
      this.newTags.forEach(tagName => {
        const hiddenInput = document.createElement('input')
        hiddenInput.type = 'hidden'
        hiddenInput.name = 'journal_entry[new_tags][]'
        hiddenInput.value = tagName
        newTagsField.parentNode.appendChild(hiddenInput)
      })
    }
  }

  clearSuggestions() {
    this.listTarget.innerHTML = ''
  }

  // Handle input events
  inputTargetConnected() {
    this.inputTarget.addEventListener('input', this.inputChanged.bind(this))
    this.inputTarget.addEventListener('keydown', this.handleKeydown.bind(this))
  }

  handleKeydown(event) {
    if (event.key === 'Enter') {
      event.preventDefault()
      const query = this.inputTarget.value.trim()
      if (query) {
        // If there's a suggestion visible, select the first one
        const firstSuggestion = this.listTarget.querySelector('[data-type]')
        if (firstSuggestion) {
          const type = firstSuggestion.dataset.type
          const value = firstSuggestion.dataset.value
          const text = firstSuggestion.textContent
          this.selectTag(type, value, text)
        } else {
          // Otherwise, create a new tag
          this.selectTag('new', query, query)
        }
      }
    }
  }
}

