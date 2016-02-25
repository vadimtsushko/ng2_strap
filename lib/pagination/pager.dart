part of pagination;

@Component (selector: "n2s-pager",
    templateUrl: 'pager.html')
class Pager {
  Pager(this.elementRef);

  /// Contains the current dom-element
  ElementRef elementRef;

  /// label of previous text
  @Input() String previousText = "« Previous";

  /// label of next text
  @Input() String nextText = "Next »";

  /// if `true` aligns each link to the sides of pager
  @Input() bool align = true;

  /// if `true` the pagination component is disabled and cannot be used.
  @Input() bool disabled = false;

  int _currentPage = 1;

  int get currentPage => _currentPage;

  @Input() set currentPage(num value) {
    _currentPage = value ?? 1;
    currentPageChange.emit(_currentPage);
  }

  @Output() EventEmitter currentPageChange = new EventEmitter();

  int _totalPages = 10;

  get totalPages => _totalPages;

  set totalPages(int v) {
    _totalPages = v;
    totalPagesChange.emit(v);
  }

  @Output() EventEmitter totalPagesChange = new EventEmitter();

  int _itemsPerPage = 10;

  get itemsPerPage => _itemsPerPage;

  @Input() set itemsPerPage(int v) {
    _itemsPerPage = v;
    totalPages = _calculateTotalPages();
  }

  int _totalItems = 10;

  int get totalItems => _totalItems;

  @Input() set totalItems(int v) {
    _totalItems = v;
    totalPages = _calculateTotalPages();
  }

  /// calculates total pages
  _calculateTotalPages() {
    var totalPages = itemsPerPage < 1 ? 1 : (totalItems / itemsPerPage).ceil();
    return max(totalPages ?? 0, 1);
  }

  /// checks if there is no previous page
  noPrevious() => currentPage <= 1;

  /// checks if there is no next page
  noNext() => currentPage >= totalPages;

  /// sets clicked item as selected
  selectPage(num _page, [MouseEvent event]) {
    if (event != null) {
      event.preventDefault();
    }
    if ((!disabled || event == null)
        && currentPage != _page
        && _page > 0
        && _page <= totalPages) {
      dynamic target = event.target;
      target.blur();
      currentPage = _page;
      totalPagesChange.emit(_page);
    }
  }

}
