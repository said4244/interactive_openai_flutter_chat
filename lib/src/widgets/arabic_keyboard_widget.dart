import 'package:flutter/material.dart';
import '../utils/arabic_keyboard.dart';
import '../models/chat_message.dart';

class ArabicKeyboardWidget extends StatefulWidget {
  final Function(String character) onKeyPressed;
  final VoidCallback onBackspace;
  final VoidCallback onSpace;
  final VoidCallback? onEnter;
  final InputState? currentInputState;
  final bool highlightNextKey;
  final bool enabled;

  const ArabicKeyboardWidget({
    Key? key,
    required this.onKeyPressed,
    required this.onBackspace,
    required this.onSpace,
    this.onEnter,
    this.currentInputState,
    this.highlightNextKey = true,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<ArabicKeyboardWidget> createState() => _ArabicKeyboardWidgetState();
}

class _ArabicKeyboardWidgetState extends State<ArabicKeyboardWidget> {
  bool _isShiftPressed = false;
  String? _selectedBaseKey; // For showing diacritic options
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Diacritics popup if a base key is selected
              if (_selectedBaseKey != null && 
                  ArabicKeyboard.hasDiacritics(_selectedBaseKey!))
                _buildDiacriticsRow(_selectedBaseKey!),
              
              // Main keyboard rows
              ...ArabicKeyboard.layout.asMap().entries.map((entry) {
                final rowIndex = entry.key;
                final row = entry.value;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildRowKeys(row, rowIndex),
                  ),
                );
              }),
              
              // Special keys row
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSpecialKey(
                      context,
                      'Shift',
                      () {
                        setState(() {
                          _isShiftPressed = !_isShiftPressed;
                        });
                      },
                      color: _isShiftPressed ? Colors.blue : null,
                      flex: 1,
                    ),
                    const SizedBox(width: 4),
                    _buildSpecialKey(
                      context,
                      ArabicKeyboard.enter,
                      widget.onEnter ?? () {},
                      flex: 1,
                    ),
                    const SizedBox(width: 4),
                    _buildSpecialKey(
                      context,
                      ArabicKeyboard.backspace,
                      widget.onBackspace,
                      color: _shouldHighlightBackspace() ? Colors.orange : null,
                      flex: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRowKeys(List<String> row, int rowIndex) {
    final keys = <Widget>[];
    
    for (final key in row) {
      if (key == ' ') {
        // Space bar
        keys.add(
          Expanded(
            flex: 3,
            child: _buildSpecialKey(
              context,
              'مسافة',
              widget.onSpace,
            ),
          ),
        );
      } else {
        // Regular key
        keys.add(_buildKey(context, key));
      }
    }
    
    return keys;
  }

  Widget _buildKey(BuildContext context, String character) {
    // Check if shift is pressed and we have a shift mapping
    String displayChar = character;
    if (_isShiftPressed && ArabicKeyboard.shiftMappings.containsKey(character)) {
      displayChar = ArabicKeyboard.shiftMappings[character]!;
    }
    
    final shouldHighlight = _shouldHighlightKey(character) || _shouldHighlightKey(displayChar);
    final isEnabled = widget.enabled;
    final hasDiacritics = ArabicKeyboard.hasDiacritics(character);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: GestureDetector(
        onLongPress: hasDiacritics && isEnabled
            ? () {
                setState(() {
                  _selectedBaseKey = character;
                });
              }
            : null,
        child: Material(
          color: shouldHighlight 
              ? Colors.green[300] 
              : (_selectedBaseKey == character ? Colors.blue[200] : Colors.white),
          borderRadius: BorderRadius.circular(8),
          elevation: shouldHighlight ? 4 : 2,
          child: InkWell(
            onTap: isEnabled 
                ? () {
                    widget.onKeyPressed(displayChar);
                    setState(() {
                      _selectedBaseKey = null;
                      if (_isShiftPressed) {
                        _isShiftPressed = false;
                      }
                    });
                  }
                : null,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: _getKeyWidth(character),
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: shouldHighlight 
                      ? Colors.green[700]! 
                      : (_selectedBaseKey == character 
                          ? Colors.blue[400]!
                          : Colors.grey[400]!),
                  width: shouldHighlight || _selectedBaseKey == character ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    displayChar,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: shouldHighlight ? FontWeight.bold : FontWeight.normal,
                      color: isEnabled ? Colors.black : Colors.grey,
                    ),
                  ),
                  if (hasDiacritics)
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildDiacriticsRow(String baseKey) {
    final diacritics = ArabicKeyboard.getDiacritics(baseKey);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: diacritics.map((variant) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              elevation: 2,
              child: InkWell(
                onTap: () {
                  widget.onKeyPressed(variant);
                  setState(() {
                    _selectedBaseKey = null;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    variant,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  double _getKeyWidth(String character) {
    // Adjust key width based on character
    if (character == ' ') return 120;
    if (character.length > 1) return 48; // For special chars like 'لا'
    return 32;
  }

  Widget _buildSpecialKey(
    BuildContext context,
    String label,
    VoidCallback onPressed, {
    int flex = 1,
    Color? color,
  }) {
    final isEnabled = widget.enabled;
    
    return Material(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(8),
      elevation: 2,
      child: InkWell(
        onTap: isEnabled ? onPressed : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color != null ? Colors.orange[700]! : Colors.grey[400]!,
              width: color != null ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isEnabled ? Colors.black : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  bool _shouldHighlightKey(String character) {
    if (!widget.highlightNextKey || widget.currentInputState == null) return false;
    
    final expectedInput = widget.currentInputState!.expectedInput;
    final currentLength = widget.currentInputState!.characterStates
        .where((s) => s.status != CharacterStatus.pending)
        .length;
    
    // If we've typed everything, don't highlight anything
    if (currentLength >= expectedInput.length) return false;
    
    // Get the next expected character
    final nextChar = expectedInput[currentLength];
    
    // Check if this character matches directly
    if (character == nextChar) return true;
    
    // Check if this is a base character for the expected character
    final baseChar = ArabicKeyboard.getBaseCharacter(nextChar);
    if (baseChar != null && character == baseChar) {
      return true;
    }
    
    // Check if this character could produce the expected character with shift
    if (_isShiftPressed && ArabicKeyboard.shiftMappings[character] == nextChar) {
      return true;
    }
    
    return false;
  }

  bool _shouldHighlightBackspace() {
    if (widget.currentInputState == null) return false;
    
    // Highlight backspace if there are incorrect characters
    return widget.currentInputState!.characterStates
        .any((s) => s.status == CharacterStatus.incorrect);
  }
}