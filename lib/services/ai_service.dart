import 'dart:async';
import 'dart:math';
import '../models/message.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  final Random _random = Random();

  // Mock legal scenarios with humorous responses
  final List<Map<String, dynamic>> _mockResponses = [
    {
      'keywords': ['contract', 'agreement', 'breach'],
      'response': '''Based on the contract law principles you've described, here are the relevant legal precedents:

The fundamental issue appears to center on breach of contract. In contract law, a material breach occurs when one party's failure to perform substantially defeats the purpose of the contract.

**Key Legal Principles:**
1. **Material vs. Minor Breach**: Courts distinguish between breaches that go to the essence of the contract versus those that are merely incidental.
2. **Substantial Performance Doctrine**: Even if there are minor deviations, substantial performance may still satisfy contractual obligations.
3. **Damages**: The non-breaching party may be entitled to compensatory damages to put them in the position they would have been in had the contract been performed.''',
      'citations': [
        {
          'caseTitle': 'Jacob & Youngs v. Kent',
          'citation': '230 N.Y. 239',
          'court': 'N.Y. Court of Appeals',
          'year': '1921',
          'summary': 'Established the substantial performance doctrine in construction contracts.',
          'type': 'caselaw'
        },
        {
          'caseTitle': 'Hadley v. Baxendale',
          'citation': '9 Ex. 341',
          'court': 'Court of Exchequer',
          'year': '1854',
          'summary': 'Landmark case establishing the rule for consequential damages in contract breach.',
          'type': 'caselaw'
        }
      ]
    },
    {
      'keywords': ['property', 'real estate', 'landlord', 'tenant'],
      'response': '''Your property law question touches on several important landlord-tenant principles. Let me break down the relevant legal framework:

**Landlord-Tenant Law Overview:**
The relationship between landlords and tenants is governed by both statutory law and common law principles. The key areas of concern typically involve:

1. **Warranty of Habitability**: Landlords have an implied duty to maintain rental properties in habitable condition.
2. **Quiet Enjoyment**: Tenants have the right to use their rental property without unreasonable interference from the landlord.
3. **Security Deposits**: Specific statutory requirements govern how security deposits must be handled.

**Remedies Available:**
- Rent withholding (in jurisdictions that permit it)
- Repair and deduct
- Constructive eviction claims
- Damages for breach of warranty of habitability''',
      'citations': [
        {
          'caseTitle': 'Javins v. First National Realty Corp.',
          'citation': '428 F.2d 1071',
          'court': 'D.C. Circuit',
          'year': '1970',
          'summary': 'Established implied warranty of habitability in residential leases.',
          'type': 'caselaw'
        }
      ]
    },
    {
      'keywords': ['tort', 'negligence', 'liability'],
      'response': '''Your negligence question involves classic tort law analysis. Here's the legal framework:

**Elements of Negligence:**
To establish a negligence claim, the plaintiff must prove four elements:
1. **Duty**: Defendant owed a legal duty to the plaintiff
2. **Breach**: Defendant breached that duty through action or inaction
3. **Causation**: Defendant's breach was both the factual and proximate cause of plaintiff's harm
4. **Damages**: Plaintiff suffered actual harm or damages

**The Reasonable Person Standard:**
The standard of care is typically that of a "reasonably prudent person" under similar circumstances. This is an objective standard that doesn't account for the defendant's particular limitations or expertise (unless they hold themselves out as having special skills).

**Comparative vs. Contributory Negligence:**
- Most jurisdictions now follow comparative negligence rules
- Pure comparative negligence allows recovery even if plaintiff is 99% at fault
- Modified comparative negligence bars recovery if plaintiff is 50% or 51% at fault''',
      'citations': [
        {
          'caseTitle': 'Palsgraf v. Long Island Railroad Co.',
          'citation': '248 N.Y. 339',
          'court': 'N.Y. Court of Appeals',
          'year': '1928',
          'summary': 'Landmark case on proximate cause and the scope of liability in negligence.',
          'type': 'caselaw'
        },
        {
          'caseTitle': 'Vaughan v. Menlove',
          'citation': '3 Bing. N.C. 468',
          'court': 'Common Pleas',
          'year': '1837',
          'summary': 'Established the objective reasonable person standard in negligence law.',
          'type': 'caselaw'
        }
      ]
    }
  ];

  Future<Message> sendMessage(String userMessage) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 800 + _random.nextInt(1200)));

    // Find matching response based on keywords
    Map<String, dynamic>? matchedResponse;
    for (final response in _mockResponses) {
      final keywords = response['keywords'] as List<String>;
      if (keywords.any((keyword) => 
          userMessage.toLowerCase().contains(keyword.toLowerCase()))) {
        matchedResponse = response;
        break;
      }
    }

    // Default response if no keywords match
    if (matchedResponse == null) {
      matchedResponse = {
        'response': '''Thank you for your legal question. While I don't have specific precedents immediately available for this particular issue, I can provide some general guidance:

**General Legal Research Approach:**
1. **Identify the Area of Law**: Determine whether this falls under contract, tort, property, criminal, or constitutional law
2. **Research Statutory Framework**: Check relevant federal and state statutes
3. **Case Law Research**: Look for similar fact patterns in reported decisions
4. **Secondary Sources**: Consult legal treatises, law review articles, and practice guides

**Next Steps:**
I recommend conducting more targeted research using legal databases like Westlaw or Lexis to find cases with similar fact patterns. You may also want to consult relevant practice guides in this area of law.

Would you like me to help you refine your search terms or identify the specific legal issues involved?''',
        'citations': []
      };
    }

    final citations = (matchedResponse['citations'] as List?)
        ?.map((c) => LegalCitation.fromJson(c))
        .toList() ?? [];

    return Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: matchedResponse['response'],
      isUser: false,
      timestamp: DateTime.now(),
      citations: citations.isNotEmpty ? citations : null,
    );
  }

  // TODO: Replace with actual API integration
  /*
  Future<Message> sendMessageToAPI(String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse('YOUR_API_ENDPOINT'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_API_KEY',
        },
        body: jsonEncode({
          'message': userMessage,
          'conversation_id': 'current_conversation_id',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Message.fromJson(data);
      } else {
        throw Exception('Failed to get AI response');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  */
}
